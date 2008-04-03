From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] ibm_newemac: Add support for 460EX/GT-type MAL  rx-channel handling
Date: Thu, 3 Apr 2008 14:35:39 +0200
Message-ID: <200804031435.39999.sr@denx.de>
References: <1207223110-27281-1-git-send-email-sr@denx.de> <1207225740.10388.321.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:58215 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832AbYDCMfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 08:35:55 -0400
In-Reply-To: <1207225740.10388.321.camel@pasglop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 April 2008, Benjamin Herrenschmidt wrote:
> On Thu, 2008-04-03 at 13:45 +0200, Stefan Roese wrote:
> > On some 4xx PPC's (e.g. 460EX/GT), the rx channel number is a multiple
> > of 8 (e.g. 8 for EMAC1, 16 for EMAC2), but enabling in MAL_RXCASR needs
> > the divided by 8 value for the bitmask.
>
> Sounds ok, but I wonder if we ever have a MAL with more than 8 chans, do
> we need to make this shift conditional to some device tree prop ?

I suggest we postpone such a conditional setup until we see such a MAL. OK?

Best regards,
Stefan
