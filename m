From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fs_enet: fix reference counting for phy_node
Date: Thu, 07 Aug 2014 16:07:13 -0700 (PDT)
Message-ID: <20140807.160713.557740387140282430.davem@davemloft.net>
References: <1407445560-20500-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com, kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53690 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696AbaHGXHO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:07:14 -0400
In-Reply-To: <1407445560-20500-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Thu,  7 Aug 2014 23:06:00 +0200

> Make sure that fs_enet_probe is left with a reference to the phy node=
=2E
> In the presence of a phy handle this is already the case as
> of_parse_phandle returns a reference. In the fixed phy case a call to
> of_node_get is necessary. Otherwise the error path and remove functio=
n
> drop a reference the driver isn't holding.
>=20
> Fixes: bb74d9a4a87b ("fs_enet: use the new fixed PHY helpers")
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied.
