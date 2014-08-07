From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: Fix reference counting for phy_node
Date: Thu, 07 Aug 2014 16:06:01 -0700 (PDT)
Message-ID: <20140807.160601.2147481708099136783.davem@davemloft.net>
References: <1407441526-25711-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	f.fainelli@gmail.com, thomas.petazzoni@free-electrons.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306AbaHGXGD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:06:03 -0400
In-Reply-To: <1407441526-25711-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Thu,  7 Aug 2014 21:58:46 +0200

> If there is a "phy" handle the probe function returns with holding a
> reference to that node. Make sure that in the fixed phy case there is
> also held a reference to yield a consistant state.
>=20
> Also add the corresponding of_node_put in the error path and the remo=
ve
> function.
>=20
> Fixes: 83895bedeee6 ("net: mvneta: add support for fixed links")
> Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP n=
etwork unit")
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied.
