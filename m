From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: gianfar: fix reference counting for phy_node
Date: Thu, 07 Aug 2014 16:06:09 -0700 (PDT)
Message-ID: <20140807.160609.329034989608056160.davem@davemloft.net>
References: <1407441707-27172-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<1407442627-1508-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com,
	kernel@pengutronix.de, f.fainelli@gmail.com,
	fabio.estevam@freescale.com, thomas.petazzoni@free-electrons.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53654 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306AbaHGXGK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:06:10 -0400
In-Reply-To: <1407442627-1508-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Thu,  7 Aug 2014 22:17:07 +0200

> The line before the changed if condition is:
>=20
> 	priv->phy_node =3D of_parse_phandle(np, "phy-handle", 0);
>=20
> . If this call succeeds priv->phy_node must not be overwritten in the=
 if
> block; otherwise the reference to the node returned by of_parse_phand=
le
> is lost. So add a check that the if block isn't executed in this case=
=2E
>=20
> Furthermore in the fixed phy case no reference is aquired for phy_nod=
e
> resulting in an of_node_put without holding a reference. To fix that,
> get a reference on the MAC dt node.
>=20
> Fixes: be40364544bd ("gianfar: use the new fixed PHY helpers")
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied.
