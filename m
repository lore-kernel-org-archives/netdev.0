From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] fec: fix recursive locking of mii_lock
Date: Wed, 02 Sep 2009 23:17:01 -0700 (PDT)
Message-ID: <20090902.231701.09584427.davem@davemloft.net>
References: <20090831132200.GA21836@pengutronix.de>
	<1251882856-23549-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<4A9F18E0.3060307@snapgear.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: u.kleine-koenig@pengutronix.de, linux-rt-users@vger.kernel.org,
	ben@decadent.org.uk, kaber@trash.net, s.hauer@pengutronix.de,
	Matt.Waddel@freescale.com, netdev@vger.kernel.org,
	tim01@vlsi.informatik.tu-darmstadt.de
To: gerg@snapgear.com
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <4A9F18E0.3060307@snapgear.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Greg Ungerer <gerg@snapgear.com>
Date: Thu, 03 Sep 2009 11:16:16 +1000

> Hi Uwe,
>=20
> Uwe Kleine-K=F6nig wrote:
>> mii_discover_phy is only called by fec_enet_mii (via mip->mii_func).
>> So
>> &fep->mii_lock is already held and mii_discover_phy must not call
>> mii_queue which locks &fep->mii_lock, too.
>> This was noticed by lockdep:
 ...
>> 	...
>> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>> Cc: Greg Ungerer <gerg@uclinux.org>
>=20
> Looks good too.
>=20
> Acked-by: Greg Ungerer <gerg@uclinux.org>

Applied to net-next-2.6
--
To unsubscribe from this list: send the line "unsubscribe linux-rt-user=
s" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
