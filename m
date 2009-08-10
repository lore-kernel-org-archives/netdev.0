From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] [NET] ixp2000/enp2611: don't set non-existent
 member get_stats
Date: Sun, 09 Aug 2009 21:49:06 -0700 (PDT)
Message-ID: <20090809.214906.143672876.davem@davemloft.net>
References: <20090807203939.GA19374@pengutronix.de>
	<1249677761-19470-5-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org, linux@arm.linux.org.uk,
	dbaryshkov@gmail.com, kernel@wantstofly.org, netdev@vger.kernel.org
To: u.kleine-koenig@pengutronix.de
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <1249677761-19470-5-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Fri,  7 Aug 2009 22:42:40 +0200

> This fixes a build failure for 2.6.31-rc5 (ARCH=3Darm, ixp2000_defcon=
fig):
>=20
> 	  CC      drivers/net/ixp2000/enp2611.o
> 	drivers/net/ixp2000/enp2611.c: In function 'enp2611_init_module':
> 	drivers/net/ixp2000/enp2611.c:213: error: 'struct net_device' has no=
 member named 'get_stats'
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

This is far from the way to fix this, unfortunately.

We need to find a way to propagate this assignment into
the netdev_ops method vector instead.
--
To unsubscribe from this list: send the line "unsubscribe linux-rt-user=
s" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
