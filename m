From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 06:23:36 -0700 (PDT)
Message-ID: <20090311.062336.238430706.davem@davemloft.net>
References: <20090311.014957.117115597.davem@davemloft.net>
	<20090311085721.GV425@pengutronix.de>
	<20090311090938.E7BF7832E8B8@gemini.denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	dzu@denx.de
To: wd@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35650
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753772AbZCKNXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 09:23:51 -0400
In-Reply-To: <20090311090938.E7BF7832E8B8@gemini.denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Denk <wd@denx.de>
Date: Wed, 11 Mar 2009 10:09:38 +0100

> How do you then handle situations where this is impossible? Say, when
> the firmware cannot write to those registers for example because  the
> ethernet  controller is not even powered on (to reduce power consump-
> tion), but will get powered on only in Linux  when  the  driver  gets
> loaded (i. e. on demand only, not always)?

That's what NVRAM, CMOS, EEPROM's and other writable long-term
storage areas are for.

To be quite honest with you, any ethernet device that doesn't
have an EEPROM where the chip instance's ethernet address is
stored is completely broken.
