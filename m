From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH V3] CAN: Add Flexcan CAN controller driver
Date: Thu, 30 Jul 2009 22:22:11 +0200
Message-ID: <4A7200F3.3010608@grandegger.com>
References: <20090729082010.GZ2714@pengutronix.de>	<4A7011BA.7040906@grandegger.com>	<20090730083729.GC2714@pengutronix.de>	<4A715F0E.2070605@grandegger.com>	<20090730092730.GD2714@pengutronix.de> <4A719463.2060201@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:34704 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbZG3UWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 16:22:14 -0400
In-Reply-To: <4A719463.2060201@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> Sascha Hauer wrote:
[...]
>> 	errcnt = readl(&regs->errcnt);
>> 	rxerr = (errcnt >> 8) & 0xff;
>> 	txerr = errcnt & 0xff;
>> 	if ((rxerr >= 96 || txerr >= 96) && state == CAN_STATE_ERROR_ACTIVE)
>> 		state = CAN_STATE_ERROR_WARNING;
> 
> Yes, or do not handle the state in the "case 0" above appropriately. The
> CAN spec only specifies the bus error states error active, error passive
> and bus off. The warning is somehow optional but available on most CAN
> controllers. Nevertheless, we should create a message if the ISR
> realizes a state changes.

FYI, I will be on holiday for the next 1.5 weeks.

Wolfgang.
