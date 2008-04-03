From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Add support for 460EX/GT-type MAL
	rx-channel handling
Date: Fri, 04 Apr 2008 00:10:20 +1100
Message-ID: <1207228220.10388.323.camel@pasglop>
References: <1207223110-27281-1-git-send-email-sr@denx.de>
	 <1207225740.10388.321.camel@pasglop>  <200804031435.39999.sr@denx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54178 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751902AbYDCNLD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2008 09:11:03 -0400
In-Reply-To: <200804031435.39999.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-04-03 at 14:35 +0200, Stefan Roese wrote:
> On Thursday 03 April 2008, Benjamin Herrenschmidt wrote:
> > On Thu, 2008-04-03 at 13:45 +0200, Stefan Roese wrote:
> > > On some 4xx PPC's (e.g. 460EX/GT), the rx channel number is a multiple
> > > of 8 (e.g. 8 for EMAC1, 16 for EMAC2), but enabling in MAL_RXCASR needs
> > > the divided by 8 value for the bitmask.
> >
> > Sounds ok, but I wonder if we ever have a MAL with more than 8 chans, do
> > we need to make this shift conditional to some device tree prop ?
> 
> I suggest we postpone such a conditional setup until we see such a MAL. OK?

Agreed. I got a bit carried away..

Ben.


