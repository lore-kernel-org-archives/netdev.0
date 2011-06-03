From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] iproute: Ignore all output fields of ip route get for
 route add
Date: Fri, 03 Jun 2011 02:07:59 -0700 (PDT)
Message-ID: <20110603.020759.797628983600553809.davem@davemloft.net>
References: <20110603083918.GA15883@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424Ab1FCJIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 05:08:12 -0400
In-Reply-To: <20110603083918.GA15883@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Fri, 3 Jun 2011 10:39:18 +0200

> My vpnc-connect script broke in a kernel release because the new
> kernel started returning the ipid in ip cache get. The script
> would do ip route get, modify the route and then feed it back
> to ip route add. But ip route add couldn't parse ipid ..
> 
> Make route add skip all status fields output by ip cache get
> 
> In theory they could be fed to the kernel too, but that's likely
> not very useful (and I'm not fully sure if the kernel would
> even use them)
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

I think we've had this discussion before.

There are no guarentees that what the tool outputs for routes is
suitable for creating routes.

People have already put vpnc script fixes into Fedora and similar
already.

iproute2 is not where the hacks belong.
