From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: ugg_geth: Fix build error in -next
Date: Mon, 11 Aug 2014 07:35:16 +0200
Message-ID: <20140811053516.GE5134@pengutronix.de>
References: <1407687554-14539-1-git-send-email-linux@roeck-us.net>
 <20140810183622.GC5134@pengutronix.de>
 <53E7BD21.6010301@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Li Yang <leoli@freescale.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56784 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752179AbaHKFf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 01:35:27 -0400
Content-Disposition: inline
In-Reply-To: <53E7BD21.6010301@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Guenter,

On Sun, Aug 10, 2014 at 11:42:41AM -0700, Guenter Roeck wrote:
> On 08/10/2014 11:36 AM, Uwe Kleine-K=F6nig wrote:
> >On Sun, Aug 10, 2014 at 09:19:14AM -0700, Guenter Roeck wrote:
> >>powerpc:mpc83xx_defconfig and other builds fail with
> >>
> >>drivers/net/ethernet/freescale/ucc_geth.c: In function 'ucc_geth_re=
move':
> >>drivers/net/ethernet/freescale/ucc_geth.c:3927:19: error:
> >>	'struct ucc_geth_private' has no member named 'info'
> >>   of_node_put(ugeth->info->tbi_node);
> >>                      ^
> >>drivers/net/ethernet/freescale/ucc_geth.c:3928:19: error:
> >>	     'struct ucc_geth_private' has no member named 'info'
> >>   of_node_put(ugeth->info->phy_node);
> >>   		     ^
> >>
> >>Introduced by commit "net: ucc_geth: drop acquired references in pr=
obe error
> >>path and remove".
> >>
> >> From the context, it appears that the variable is named ug_info.
> >>
> >>Cc: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> >>Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> >>---
> >>Only seen in -next.
> >My patch was only sent just now, but it has the subject right:
> >
> Excellent.
>=20
> >	http://mid.gmane.org/1407695525-32227-1-git-send-email-u.kleine-koe=
nig@pengutronix.de
> >
> The link doesn't seem to work for some reason.
It didn't work for me when I sent the mail either. I thought gmane will
have indexed the mail in a few minutes though. Gmane is broken somehow,
when I follow the Subject link of
http://article.gmane.org/gmane.linux.network/326013 I also get a No suc=
h
article page?! :-(

http://patchwork.ozlabs.org/patch/378854/ is a link that works for me.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
