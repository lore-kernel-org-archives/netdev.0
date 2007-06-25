From: Erik Slagter <erik@slagter.name>
Subject: Re: Linksys Gigabit USB2.0 adapter (asix) regression
Date: Mon, 25 Jun 2007 19:05:31 +0200
Message-ID: <467FF5DB.5090006@slagter.name>
References: <467915D9.3030900@slagter.name> <1182523020.4938.20.camel@dhollis-lnx.sunera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Hollis <dhollis@davehollis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from erik-slagter.demon.nl ([83.160.41.216]:47015 "EHLO
	artemis.slagter.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750927AbXFYRFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 13:05:33 -0400
In-Reply-To: <1182523020.4938.20.camel@dhollis-lnx.sunera.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Hollis wrote:

> You wouldn't happen to know what PHY that device is using?  The AX88178
> (Gigabit USB Ethernet) support in the driver currently only supports the
> Marvell PHY, which is the only one I've actually encountered to-date.

I'll quote a few of strings that are spewed that I assume might be
interesting:

drivers/net/usb/asix.c: GPIO Status: 0x0002
drivers/net/usb/asix.c: EEPROM index 0x17 is 0x0580
drivers/net/usb/asix.c: GPIO0: 0, PhyMode: 0
drivers/net/usb/asix.c: PHYID=0x01410cc2
usb%d: MII_MARVELL_STATUS = 0x848f
usb%d: MII_MARVELL_LED_CTRL (1) = 0x4100
usb%d: MII_MARVELL_LED_CTRL (2) = 0x4101

