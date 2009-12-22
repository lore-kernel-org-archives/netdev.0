From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] wireless: adf702x: new driver for ADF7020/21 parts
Date: Mon, 21 Dec 2009 19:05:02 -0800
Message-ID: <1261451102.4041.170.camel@localhost.localdomain>
References: <1261447929-17106-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Michael Hennerich <michael.hennerich@analog.com>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:40613 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbZLVDF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 22:05:29 -0500
In-Reply-To: <1261447929-17106-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mike,

> This is a driver for Analog Devices series of ADF702x Narrow-Band
> Short-Range Radio Transceiver chipsets, including the ADF7021 and
> the ADF7025.  This Ethernet like driver implements a custom
> software PHY.

while it might be a little bit confusing, but the wireless directory
normally only contains Wireless LAN (aka 802.11 and alike) drivers.

If this implements some sort of Ethernet driver, then it might be better
to just put it under drivers/net/ to not intermix and confuse it with
actually 802.11 drivers.

>  drivers/net/wireless/Kconfig   |   11 +
>  drivers/net/wireless/Makefile  |    2 +
>  drivers/net/wireless/adf702x.c |  788 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/spi/adf702x.h    |   33 ++
>  4 files changed, 834 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/wireless/adf702x.c
>  create mode 100644 include/linux/spi/adf702x.h

And why is the header file under SPI includes. It could be as easily in
the same directory as the driver *.c file itself. No reason to spread it
over the whole tree if nothing else includes it.

Regards

Marcel


