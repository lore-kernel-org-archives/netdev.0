From: David Miller <davem@davemloft.net>
Subject: Re: sch_generic warn_on (timed out)
Date: Mon, 11 Jul 2011 14:17:01 -0700 (PDT)
Message-ID: <20110711.141701.1453197953333902027.davem@davemloft.net>
References: <20110711204834.GA4950@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960Ab1GKVRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 17:17:07 -0400
In-Reply-To: <20110711204834.GA4950@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 11 Jul 2011 16:48:34 -0400

> We've recieved quite a few bug reports in Fedora recently concerning this warning in
> sch_generic..
> 
>             WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queue %u timed out\n",
>                       dev->name, netdev_drivername(dev, drivername, 64), i);
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=702723 is our 'master bug' that we're
> duping all others against. It seems to be showing up on a variety of different
> hardware (r8169, atl1c, ipheth, e1000e, 8139too). Do all these drivers need
> fixing ? or is it just 'crap hardware' ?
> 
> note that I've only been looking through fedora 15 bugs so far (which is still on 2.6.38),
> but looking at the commit log for sch_generic, it doesn't seem that there's anything
> obvious that needs backporting.

It means the transmitter stopped sending packets for several seconds.

I would track this on a per-device basis if I were you, instead of
combining them all into one super-bug.
