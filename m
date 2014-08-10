From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: ugg_geth: Fix build error in -next
Date: Sun, 10 Aug 2014 20:36:22 +0200
Message-ID: <20140810183622.GC5134@pengutronix.de>
References: <1407687554-14539-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Li Yang <leoli@freescale.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59213 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022AbaHJSg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2014 14:36:26 -0400
Content-Disposition: inline
In-Reply-To: <1407687554-14539-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Guenter,

On Sun, Aug 10, 2014 at 09:19:14AM -0700, Guenter Roeck wrote:
> powerpc:mpc83xx_defconfig and other builds fail with
>=20
> drivers/net/ethernet/freescale/ucc_geth.c: In function 'ucc_geth_remo=
ve':
> drivers/net/ethernet/freescale/ucc_geth.c:3927:19: error:
> 	'struct ucc_geth_private' has no member named 'info'
>   of_node_put(ugeth->info->tbi_node);
>                      ^
> drivers/net/ethernet/freescale/ucc_geth.c:3928:19: error:
> 	     'struct ucc_geth_private' has no member named 'info'
>   of_node_put(ugeth->info->phy_node);
>   		     ^
>=20
> Introduced by commit "net: ucc_geth: drop acquired references in prob=
e error
> path and remove".
>=20
> From the context, it appears that the variable is named ug_info.
>=20
> Cc: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
> Only seen in -next.
My patch was only sent just now, but it has the subject right:

	http://mid.gmane.org/1407695525-32227-1-git-send-email-u.kleine-koenig=
@pengutronix.de

Another upside is that it contains a Fixes: header.

Other than that my patch is the same. In case davem picks up yours:

Acked-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Best regards and thanks
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
