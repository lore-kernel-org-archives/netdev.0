From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] can: pch_can: fix section mismatch warning by
 using a whitelisted name
Date: Sat, 30 Oct 2010 16:28:31 -0700 (PDT)
Message-ID: <20101030.162831.260085538.davem@davemloft.net>
References: <1288168706-870-1-git-send-email-mkl@pengutronix.de>
	<1288168706-870-3-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	tomoya-linux@dsn.okisemi.com
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47909
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754042Ab0J3X2I convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Oct 2010 19:28:08 -0400
In-Reply-To: <1288168706-870-3-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 27 Oct 2010 10:38:26 +0200

> This patch fixes the following section mismatch warning:
>=20
> WARNING: drivers/net/can/pch_can.o(.data+0x18):
> Section mismatch in reference from the variable pch_can_pcidev
> to the variable .devinit.rodata:pch_pci_tbl
> The variable pch_can_pcidev references
> the variable __devinitconst pch_pci_tbl
>=20
> This is actually a false positive which is fixed by giving the offend=
ing
> variable a whitelisted name, it's renamed to "pch_can_pci_driver".
> This makes sense because the variable is of the type "struct pci_driv=
er".
>=20
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> Acked-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied.
