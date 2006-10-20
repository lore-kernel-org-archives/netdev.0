From: Ben Collins <ben.collins@ubuntu.com>
Subject: Re: revert mv643xx change from ubuntu tree
Date: Fri, 20 Oct 2006 00:35:01 -0400
Message-ID: <1161318901.31915.21.camel@gullible>
References: <20061019121836.GA26319@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.swissdisk.com ([216.66.254.197]:40578 "EHLO
	swissweb.swissdisk.com") by vger.kernel.org with ESMTP
	id S1161021AbWJTEfS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 00:35:18 -0400
To: Olaf Hering <olaf@aepfle.de>
In-Reply-To: <20061019121836.GA26319@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-10-19 at 14:18 +0200, Olaf Hering wrote:
> Somehow the Ubuntu guys managed to sneak this compile error into the
> tree:
>=20
> commit ce9e3d9953c8cb67001719b5516da2928e956be4
>=20
>       [mv643xx] Add pci device table for auto module loading.
>=20
> drivers/net/mv643xx_eth.c:1560: error: array type has incomplete elem=
ent type
> drivers/net/mv643xx_eth.c:1561: warning: implicit declaration of func=
tion =E2=80=98PCI_DEVICE=E2=80=99
> drivers/net/mv643xx_eth.c:1561: error: =E2=80=98PCI_VENDOR_ID_MARVELL=
=E2=80=99 undeclared here (not in a function)
> drivers/net/mv643xx_eth.c:1561: error: =E2=80=98PCI_DEVICE_ID_MARVELL=
_MV64360=E2=80=99 undeclared here (not in a function)

Correct, I missed the include for linux/pci.h.

This patch has been trailing our tree since 2.6.12. Could you help me t=
o
understand what in this driver will cause it to be autoloaded by udev
when compiled as a module?
