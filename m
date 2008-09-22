From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 23 Sep 2008 01:24:28 +0200
Message-ID: <20080922232428.GA25711@one.firstfloor.org>
References: <48D81A95.5080207@redhat.com> <20080922.152615.215876787.davem@davemloft.net> <48D82378.4000306@redhat.com> <20080922.161323.108280715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, andi@firstfloor.org, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56802 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753575AbYIVXTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 19:19:38 -0400
Content-Disposition: inline
In-Reply-To: <20080922.161323.108280715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2008 at 04:13:23PM -0700, David Miller wrote:
> From: Chris Snook <csnook@redhat.com>
> Date: Mon, 22 Sep 2008 19:00:08 -0400
> 
> > Could you please point me to an example of a connection parameter
> > that gets tuned and cached this way, so I can experiment with it?
> 
> You'll find tons of them in tcp_update_metrics().

IMHO that is actually obsolete because it does not take NAT
into account. One IP does not necessarily share link characteristics.

-Andi

-- 
ak@linux.intel.com
