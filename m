From: Patrick McHardy <kaber@trash.net>
Subject: Re: Problem with VLANs and via-velocity driver
Date: Fri, 13 Nov 2009 07:40:39 +0100
Message-ID: <4AFCFF67.3060802@trash.net>
References: <20091113033217.GQ838@cubit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Shanahan <kmshanah@disenchant.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42753 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784AbZKMGkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 01:40:36 -0500
In-Reply-To: <20091113033217.GQ838@cubit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kevin Shanahan wrote:
> Hi,
> 
> I've had some problems with getting a fairly simple (I thought) VLAN
> configuration working with the on board Via NICs on my Via M700
> board. Looks like as soon as a tagged VLAN interface is added, the
> underlying "raw" (untagged) interface stops responding.
> 
> ...
> 
> A bit of searching found a few references to similar problems going
> back a few years (2005, 2007). Sounded like there were some driver
> issues, but it wasn't clear from the messages I found whether they
> were believed to be fixed or not. I tried the same test using a
> differnt NIC with the tg3 driver and there were no problems, so it
> looks to me like it's still a via-velocity issue. Unfortunately I
> don't have room to add NICs to this machine and need to use the on
> board Via hardware.

There's some special-casing for VID 0 in velocity_init_cam_filter().
Does "ip link add link eth0 type vlan id 0" make any difference?
If not, does "ip link set eth0 promisc on"?
