From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 5/6] [NET] ixp2000/enp2611: don't set non-existent
	member get_stats
Date: Mon, 10 Aug 2009 11:40:27 +0200
Message-ID: <20090810094027.GA22200@pengutronix.de>
References: <20090807203939.GA19374@pengutronix.de> <1249677761-19470-5-git-send-email-u.kleine-koenig@pengutronix.de> <20090809.214906.143672876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org, linux@arm.linux.org.uk,
	dbaryshkov@gmail.com, kernel@wantstofly.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40616 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366AbZHJJko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 05:40:44 -0400
Content-Disposition: inline
In-Reply-To: <20090809.214906.143672876.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Sun, Aug 09, 2009 at 09:49:06PM -0700, David Miller wrote:
> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Date: Fri,  7 Aug 2009 22:42:40 +0200
>=20
> > This fixes a build failure for 2.6.31-rc5 (ARCH=3Darm, ixp2000_defc=
onfig):
> >=20
> > 	  CC      drivers/net/ixp2000/enp2611.o
> > 	drivers/net/ixp2000/enp2611.c: In function 'enp2611_init_module':
> > 	drivers/net/ixp2000/enp2611.c:213: error: 'struct net_device' has =
no member named 'get_stats'
> >=20
> > Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>=20
> This is far from the way to fix this, unfortunately.
>=20
> We need to find a way to propagate this assignment into
> the netdev_ops method vector instead.
Yes, I tried that, but stopped when I saw it's declared const.  I don't
know if this is required.  If yes then the only way to fix it is to add
a platform callback that is called if non-NULL.

I don't want to invest time here without a word by the maintainers
though.

Best regards
Uwe

--=20
Pengutronix e.K.                              | Uwe Kleine-K=F6nig     =
       |
Industrial Linux Solutions                    | http://www.pengutronix.=
de/  |
