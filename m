From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Allow receiving packets on the fallback tunnel if they
 pass sanity checks
Date: Thu, 28 Jun 2012 18:09:58 -0700 (PDT)
Message-ID: <20120628.180958.61012438467797240.davem@davemloft.net>
References: <20120605154058.GA16615@ipom.com>
	<20120620.210405.2231549940491911080.davem@davemloft.net>
	<4FE92E7F.5040803@ipom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phild@fb.com
To: phil@ipom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788Ab2F2BJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 21:09:59 -0400
In-Reply-To: <4FE92E7F.5040803@ipom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Dibowitz <phil@ipom.com>
Date: Mon, 25 Jun 2012 20:37:35 -0700

> Sure. Sorry, I just kept Ville's patch description.
> 
> We do Layer-3 DSR via IP-in-IP tunneling. Our load balancers wrap an extra IP
> header on incoming packets so they can be routed to the backend. In the v4
> tunnel driver, when these packets fall on the default tunl0 device, the
> behavior is to decapsulate them and drop them back on the stack. So our setup
> is that tunl0 has the VIP and eth0 has (obviously) the backend's real address.
> 
> In IPv6 we do the same thing, but the v6 tunnel driver didn't have this same
> behavior - if you didn't have an explicit tunnel setup, it would drop the packet.
> 
> This patch brings that v4 feature to the v6 driver.
> 
> I think that's the level of detail you're looking for, but I'm happy to expand
> on anything in particular. I also break this down in tons of detail here:

This is a lot better, please resubmit the patch with a proper verbose
commit message, and please submit it properly and without any unrelated
content in the message body as described in Documentation/SubmittingPatches
