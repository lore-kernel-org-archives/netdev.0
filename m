From: Kevin Shanahan <kmshanah@disenchant.net>
Subject: Re: Problem with VLANs and via-velocity driver
Date: Mon, 16 Nov 2009 11:27:50 +1030
Message-ID: <20091116005750.GR838@cubit>
References: <20091113033217.GQ838@cubit> <4AFCFF67.3060802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail02.adl6.internode.on.net ([203.16.214.140]:31879 "EHLO
	ipmail02.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752537AbZKPA5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2009 19:57:48 -0500
Content-Disposition: inline
In-Reply-To: <4AFCFF67.3060802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 07:40:39AM +0100, Patrick McHardy wrote:
> Kevin Shanahan wrote:
> > Hi,
> > 
> > I've had some problems with getting a fairly simple (I thought) VLAN
> > configuration working with the on board Via NICs on my Via M700
> > board. Looks like as soon as a tagged VLAN interface is added, the
> > underlying "raw" (untagged) interface stops responding.
> > 
> > ...
> > 
> > A bit of searching found a few references to similar problems going
> > back a few years (2005, 2007). Sounded like there were some driver
> > issues, but it wasn't clear from the messages I found whether they
> > were believed to be fixed or not. I tried the same test using a
> > differnt NIC with the tg3 driver and there were no problems, so it
> > looks to me like it's still a via-velocity issue. Unfortunately I
> > don't have room to add NICs to this machine and need to use the on
> > board Via hardware.
> 
> There's some special-casing for VID 0 in velocity_init_cam_filter().
> Does "ip link add link eth0 type vlan id 0" make any difference?

Thanks Patrick, this command got the untagged interface working again
(eth1 in my case). I can use this as a work around.

I didn't really understand if there was a good reason for the
special-casing in this driver, but from at least from my user
perspective I think it would be better if the drivers were consistent
in how they handle this.

Regards,
Kevin Shanahan.
