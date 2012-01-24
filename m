From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH V3 4/4] CS89x0 : add CS89x0 platform device to the
 iMX31ADS board
Date: Tue, 24 Jan 2012 00:37:50 -0200
Message-ID: <CAOMZO5CH_3hEHm6=734KoYcURbGf5=BqY3eZKnwkdyFRWMDjAA@mail.gmail.com>
References: <1326571095-27921-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: s.hauer@pengutronix.de, kernel@pengutronix.de,
	u.kleine-koenig@pengutronix.de, davem@davemloft.net,
	cavokz@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40562 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922Ab2AXChv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 21:37:51 -0500
Received: by eaac13 with SMTP id c13so855704eaa.19
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2012 18:37:50 -0800 (PST)
In-Reply-To: <1326571095-27921-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 14, 2012 at 5:58 PM, Jaccon Bastiaansen
<jaccon.bastiaansen@gmail.com> wrote:

> +static const struct resource mx31ads_cs8900_resources[] __initconst =
=3D {
> + =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .start =3D MX31_CS=
4_BASE_ADDR + CS4_CS8900_MMIO_START,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .end =3D MX31_CS4_=
BASE_ADDR + CS4_CS8900_MMIO_END,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .flags =3D IORESOU=
RCE_MEM
> + =C2=A0 =C2=A0 =C2=A0 },

You can use DEFINE_RES_MEM(MX31_CS4_BASE_ADDR, SZ_64K);
> + =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .start =3D EXPIO_I=
NT_ENET_INT,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .end =3D EXPIO_INT=
_ENET_INT,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .flags =3D IORESOU=
RCE_IRQ
> + =C2=A0 =C2=A0 =C2=A0 }

And here DEFINE_RES_IRQ(EXPIO_INT_ENET_INT);

Regards,

=46abio Estevam
