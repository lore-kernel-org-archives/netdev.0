From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Is 802.3ad mode in bonding useful ?
Date: Fri, 29 Apr 2011 08:21:02 -0700
Message-ID: <1304090462.9358.1617.camel@tardy>
References: <4DB9185E.4050103@gmail.com>
	 <20110428122102.GB4165@hmsreliant.think-freely.org>
	 <4DBA2DDC.80502@gmail.com>
	 <20110429104342.GA22387@hmsreliant.think-freely.org>
	 <4DBAC552.507@hotmail.com>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	WeipingPan <panweiping3@gmail.com>, netdev@vger.kernel.org
To: John Lumby <johnlumby@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:45666 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932177Ab1D2PVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 11:21:05 -0400
In-Reply-To: <4DBAC552.507@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> What is looped back frames here ?
> > In this case they are frames that get received by the bond, which the bond
> > itself sent.  In modes where more than one slave is active, and in which the
> > switch has no additional knoweldge of the aggregate (e.g. round robin mode), the
> > bond can send a frame on one slave, which the switch may broadcast to all ports,
> 
> 
> Isn't this (broadcasting or repeating on all ports other than incoming) 
> more associated with simple hubs rather than switches?     I would think 
> any switch with layer 2 capability does not do that (does it?)

Perhaps when a frame is sent via the bond to a destination MAC not yet
learned by the switch?  

Until a switch sees a MAC as a src, it does not know to which port the
frame(s) should be forwarded, so it must send the frame out all ports
but the ingress port.

rick jones

