From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH v2] can: ti_hecc: Replace platform dependency with ARM
 dependency
Date: Fri, 20 Dec 2013 18:33:42 -0300
Message-ID: <20131220213341.GA452@localhost>
References: <1387570460-18409-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <52B4B3E7.8050601@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52B4B3E7.8050601@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 21, 2013 at 12:17:27AM +0300, Sergei Shtylyov wrote:
> On 12/20/2013 11:14 PM, Ezequiel Garcia wrote:
>=20
> > OMAP's ti_hecc driver is used to support the CAN controller on many=
 omap2plus
> > SoCs (OMAP2430, OMAP3, OMAP4, OMAP5 and AM335x), so it's wrong to m=
ake this
> > depend on OMAP3 only. Take an extra step, to get wider build covera=
ge, and make
> > the driver depend on ARM.
>=20
>     To have a real wide coverage, it's probably worth adding '|| COMI=
PLE_TEXT'=20
> to 'depends on ARCH_OMAP2PLUS'?
>=20

Yup, and that was my exact proposal on my reply to v1 (which I forgot t=
o detail
in v2). I'd say it's Marc's call.
--=20
Ezequiel Garc=C3=ADa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
