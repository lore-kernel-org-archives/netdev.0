From: Marcel Holtmann <marcel@holtmann.org>
Subject: RE: [PATCH] wireless: adf702x: new driver for ADF7020/21 parts
Date: Tue, 22 Dec 2009 04:46:56 -0800
Message-ID: <1261486016.609.4.camel@localhost.localdomain>
References: <1261447929-17106-1-git-send-email-vapier@gentoo.org>
	 <1261451102.4041.170.camel@localhost.localdomain>
	 <8A42379416420646B9BFAC9682273B6D0EF11EC1@limkexm3.ad.analog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org
To: "Hennerich, Michael" <Michael.Hennerich@analog.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:38460 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbZLVMrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 07:47:25 -0500
In-Reply-To: <8A42379416420646B9BFAC9682273B6D0EF11EC1@limkexm3.ad.analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

> >> This is a driver for Analog Devices series of ADF702x Narrow-Band
> >> Short-Range Radio Transceiver chipsets, including the ADF7021 and
> >> the ADF7025.  This Ethernet like driver implements a custom
> >> software PHY.
> >
> >while it might be a little bit confusing, but the wireless directory
> >normally only contains Wireless LAN (aka 802.11 and alike) drivers.
> >
> >If this implements some sort of Ethernet driver, then it might be better
> >to just put it under drivers/net/ to not intermix and confuse it with
> >actually 802.11 drivers.
> 
> No problem we can relocate 
> 
> >
> >>  drivers/net/wireless/Kconfig   |   11 +
> >>  drivers/net/wireless/Makefile  |    2 +
> >>  drivers/net/wireless/adf702x.c |  788
> >++++++++++++++++++++++++++++++++++++++++
> >>  include/linux/spi/adf702x.h    |   33 ++
> >>  4 files changed, 834 insertions(+), 0 deletions(-)
> >>  create mode 100644 drivers/net/wireless/adf702x.c
> >>  create mode 100644 include/linux/spi/adf702x.h
> >
> >And why is the header file under SPI includes. It could be as easily in
> >the same directory as the driver *.c file itself. No reason to spread it
> >over the whole tree if nothing else includes it.
> 
> It under include/linux/spi/ because it includes platform data which is used by board support files.

that is no argument to move it there. It is a driver specific header and
so keep it in the same location as the driver itself.

Regards

Marcel


