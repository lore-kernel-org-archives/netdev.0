From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] freescale:Make the function
 gfar_configure_coalescing_all static
Date: Tue, 7 Jul 2015 21:53:17 +0200
Message-ID: <20150707195317.GJ9671@pengutronix.de>
References: <1436298573-28541-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, claudiu.manoil@freescale.com,
	haokexin@gmail.com, matei.pavaluca@freescale.com,
	jingchang.lu@freescale.com, tobias@waldekranz.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436298573-28541-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 07, 2015 at 03:49:33PM -0400, Nicholas Krause wrote:
> This makes the function gfar_configure_coalescing_all static
> and removes its function prototype from the header file, gianfar.h
really? Looking at the diffstat I dare to disagree.

> due to this function only ever being called in its definition and
> declaration file of gainfar.c.
>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/freescale/gianfar.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
