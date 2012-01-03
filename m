From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: fsl: fec: fix build for mx23-only kernel
Date: Tue, 3 Jan 2012 13:37:47 -0200
Message-ID: <CAOMZO5BmKJP-3y_FxczuGwGfBR_3e2J9z3+gqzs-JDxOtR_PdQ@mail.gmail.com>
References: <1325598407-14353-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>,
	=?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>, Shawn Guo <shawn.guo@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:64946 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753868Ab2ACPhs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 10:37:48 -0500
Received: by eekc4 with SMTP id c4so15976500eek.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 07:37:47 -0800 (PST)
In-Reply-To: <1325598407-14353-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2012 at 11:46 AM, Wolfram Sang <w.sang@pengutronix.de> w=
rote:
> If one only selects mx23-based boards, compile fails:
>
> drivers/net/ethernet/freescale/fec.c:410:2: error: 'FEC_HASH_TABLE_HI=
GH' undeclared (first use in this function)
> drivers/net/ethernet/freescale/fec.c:411:2: error: 'FEC_HASH_TABLE_LO=
W' undeclared (first use in this function)
>
> This is because fec.h uses CONFIG_SOC_IMX28 to determine the register
> layout of the core which makes sense since the MX23 does not have a f=
ec.
> However, Kconfig uses the broader ARCH_MXS symbol and this way even
> makes the fec-driver default for MX23. Adapt Kconfig to use the more
> precise SOC_IMX28 as well.
>
> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
> Cc: Fabio Estevam <fabio.estevam@freescale.com>
> Cc: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
> Cc: Shawn Guo <shawn.guo@linaro.org>
> Cc: David S. Miller <davem@davemloft.net>

Acked-by: Fabio Estevam <fabio.estevam@freescale.com>
