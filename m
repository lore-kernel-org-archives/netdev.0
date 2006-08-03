From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Thu, 3 Aug 2006 21:40:16 +0200
Message-ID: <20060803194016.GC527@xi.wantstofly.org>
References: <44CDD631.5030008@snapgear.com> <20060731091423.3327f85e@dxpl.pdx.osdl.net> <44CEAB31.5090501@snapgear.com> <20060731220822.444f04e4@localhost.localdomain> <20060802074223.GA23715@xi.wantstofly.org> <44D15265.4090905@snapgear.com> <20060803073307.GA29775@xi.wantstofly.org> <44D1BE93.1080308@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:15830 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S932468AbWHCTkS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 15:40:18 -0400
To: Philip Craig <philipc@snapgear.com>
Content-Disposition: inline
In-Reply-To: <44D1BE93.1080308@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 07:14:59PM +1000, Philip Craig wrote:

> > So now you _need_ bridging in the middle to send ethernet traffic over
> > a GRE tunnel?  Ugh.
> 
> Agreed that would not be nice.  What is the usage scenario for this?
> At least one end of the tunnel will be bridged?

For example for VPN purposes, I could imagine that you wouldn't want
to use bridging.


> > If you really want to send ethernet and non-ethernet traffic over the
> > same tunnel, can't you make multiple devices?
> 
> Do you mean make multiple GRE devices, where one has an ethernet mode set?

For example.  If you want to send ethernet-encapsulated and other-protocol-
encapsulated traffic over the same GRE tunnel, that would seem like the
cleanest solution to me.


> > If GRE generally transmits BPDUs without ethernet header, the handling
> > for that ought to be in GRE, IMHO.
> 
> I don't think this is normal behaviour.  At least, not all routers do it.
> More likely some routers have done it as an optimisation.  It does appear
> to be specific to GRE.

Hmm, so it depends on the device whether BPDUs are sent with or without
an ethernet header?  Do the devices that send BPDUs without ethernet
header at least accept a BPDU with an ethernet header (and vice versa),
or aren't the two modes compatible at all?


cheers,
Lennert
