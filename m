From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] [004] dmfe : Add suspend/resume support
Date: Fri, 9 Feb 2007 20:54:52 +0000
Message-ID: <20070209205451.GA3949@ucw.cz>
References: <549393.8054.qm@web38506.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, tori@unhappy.mine.nu,
	netdev@vger.kernel.org
To: Levitsky Maxim <maximlevitsky@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:2811 "EHLO spitz.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1946135AbXBIXza (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 18:55:30 -0500
Content-Disposition: inline
In-Reply-To: <549393.8054.qm@web38506.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> From: Maxim Levitsky <maximlevitsky@yahoo.com>
> Subject: [PATCH] [NETDEV] [004] dmfe : Add suspend/resume support
>=20
> Adds support for suspend/resume

Patch looks ok, but your mailer damaged it heavily.

> --- linux-2.6.20-mod/drivers/net/tulip/dmfe.c=A0=A0=A02007-02-07 18:4=
6:13.000000000 +0200
> +++ linux-2.6.20-test/drivers/net/tulip/dmfe.c=A0=A02007-02-07 18:50:=
52.000000000 +0200
> @@ -55,9 +55,6 @@
> =A0
> =A0 =A0 =A0TODO
> =A0
> - =A0 =A0Implement pci_driver::suspend() and pci_driver::resume()
> - =A0 =A0power management methods.
> -
> =A0 =A0 =A0Check on 64 bit boxes.
> =A0 =A0 =A0Check and fix on big endian boxes.
> =A0
> @@ -2027,11 +2024,59 @@ static struct pci_device_id dmfe_pci_tbl
> =A0MODULE_DEVICE_TABLE(pci, dmfe_pci_tbl);
> =A0
> =A0
> +
> +static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
> +{

							Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html
