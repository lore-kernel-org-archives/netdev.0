From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: ethernet: davicom: fix devicetree irq resource
Date: Sun, 21 Feb 2016 22:41:28 -0500 (EST)
Message-ID: <20160221.224128.1565862438680728799.davem@davemloft.net>
References: <1456001126-13129-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456001126-13129-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Sat, 20 Feb 2016 21:45:26 +0100

> The dm9000 driver doesn't work in at least one device-tree
> configuration, spitting an error message on irq resource :
> [=A0=A0=A0=A01.062495] dm9000 8000000.ethernet: insufficient resource=
s
> [=A0=A0=A0=A01.068439] dm9000 8000000.ethernet: not found (-2).
> [=A0=A0=A0=A01.073451] dm9000: probe of 8000000.ethernet failed with =
error -2
>=20
> The reason behind is that the interrupt might be provided by a gpio
> controller, not probed when dm9000 is probed, and needing the probe
> deferral mechanism to apply.
>=20
> Currently, the interrupt is directly taken from resources. This patch
> changes this to use the more generic platform_get_irq(), which handle=
s
> the deferral.
>=20
> Moreover, since commit Fixes: 7085a7401ba5 ("drivers: platform: parse
> IRQ flags from resources"), the interrupt trigger flags are honored i=
n
> platform_get_irq(), so remove the needless code in dm9000.
>=20
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> Acked-by: Marcel Ziswiler <marcel@ziswiler.com>

Applied.
