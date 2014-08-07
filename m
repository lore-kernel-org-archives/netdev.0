From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bcmgenet: fix reference counting for phy node
Date: Thu, 07 Aug 2014 16:07:08 -0700 (PDT)
Message-ID: <20140807.160708.1321297135015241670.davem@davemloft.net>
References: <1407444820-16250-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755983AbaHGXHJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:07:09 -0400
In-Reply-To: <1407444820-16250-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Thu,  7 Aug 2014 22:53:40 +0200

> For the fixed phy setup make sure to not overwrite a valid value of
> phy_dn (that is holding a reference to a phy-handle) and also acquire=
 a
> reference to the MAC node to consistently return with the phy_dn poin=
ter
> holding a reference.
>=20
> Also add the corresponding of_node_put in the error path and the remo=
ve
> function.
>=20
> Fixes: 9abf0c2b717a ("net: bcmgenet: use the new fixed PHY helpers")
> Fixes: aa09677cba42 ("net: bcmgenet: add MDIO routines")
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied.
