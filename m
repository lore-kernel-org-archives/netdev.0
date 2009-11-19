From: Patrick McHardy <kaber@trash.net>
Subject: Re: Problem with VLANs and via-velocity driver
Date: Thu, 19 Nov 2009 16:18:17 +0100
Message-ID: <4B0561B9.4050600@trash.net>
References: <20091113033217.GQ838@cubit> <4AFCFF67.3060802@trash.net> <20091116005750.GR838@cubit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Shanahan <kmshanah@disenchant.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44813 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427AbZKSPSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 10:18:13 -0500
In-Reply-To: <20091116005750.GR838@cubit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kevin Shanahan wrote:
> On Fri, Nov 13, 2009 at 07:40:39AM +0100, Patrick McHardy wrote:
>> Kevin Shanahan wrote:
>>> Hi,
>>>
>>> I've had some problems with getting a fairly simple (I thought) VLAN
>>> configuration working with the on board Via NICs on my Via M700
>>> board. Looks like as soon as a tagged VLAN interface is added, the
>>> underlying "raw" (untagged) interface stops responding.
>>>
>>> ...
>>>
>>> A bit of searching found a few references to similar problems going
>>> back a few years (2005, 2007). Sounded like there were some driver
>>> issues, but it wasn't clear from the messages I found whether they
>>> were believed to be fixed or not. I tried the same test using a
>>> differnt NIC with the tg3 driver and there were no problems, so it
>>> looks to me like it's still a via-velocity issue. Unfortunately I
>>> don't have room to add NICs to this machine and need to use the on
>>> board Via hardware.
>> There's some special-casing for VID 0 in velocity_init_cam_filter().
>> Does "ip link add link eth0 type vlan id 0" make any difference?
> 
> Thanks Patrick, this command got the untagged interface working again
> (eth1 in my case). I can use this as a work around.
> 
> I didn't really understand if there was a good reason for the
> special-casing in this driver, but from at least from my user
> perspective I think it would be better if the drivers were consistent
> in how they handle this.

I agree.
