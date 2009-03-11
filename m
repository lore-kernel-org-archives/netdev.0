From: Robert Schwebel <r.schwebel@pengutronix.de>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 19:23:37 +0100
Message-ID: <20090311182337.GA5367@pengutronix.de>
References: <20090311.014957.117115597.davem@davemloft.net> <20090311085721.GV425@pengutronix.de> <20090311090938.E7BF7832E8B8@gemini.denx.de> <20090311.062336.238430706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: wd@denx.de, shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	dzu@denx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35275 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbZCKSXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 14:23:50 -0400
Content-Disposition: inline
In-Reply-To: <20090311.062336.238430706.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2009 at 06:23:36AM -0700, David Miller wrote:
> From: Wolfgang Denk <wd@denx.de>
> Date: Wed, 11 Mar 2009 10:09:38 +0100
> 
> > How do you then handle situations where this is impossible? Say, when
> > the firmware cannot write to those registers for example because  the
> > ethernet  controller is not even powered on (to reduce power consump-
> > tion), but will get powered on only in Linux  when  the  driver  gets
> > loaded (i. e. on demand only, not always)?
> 
> That's what NVRAM, CMOS, EEPROM's and other writable long-term
> storage areas are for.
> 
> To be quite honest with you, any ethernet device that doesn't
> have an EEPROM where the chip instance's ethernet address is
> stored is completely broken.

However, it's quite common in embedded systems where eeprom chips cost
money and high quantity projects are cost optimized. So we cannot
neglect reality here. I know almost no ARM board that has a separate
eeprom for the network chip, and especially SoC-integrated MAC units
don't even have hardware interfaces for that.

rsc
-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
