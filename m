From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: ucc_geth: make probe consistently acquire a
 reference to the phy node
Date: Thu, 07 Aug 2014 16:07:24 -0700 (PDT)
Message-ID: <20140807.160724.1353005428981700895.davem@davemloft.net>
References: <1407448106-1819-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<1407448106-1819-2-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: leoli@freescale.com, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, kernel@pengutronix.de, f.fainelli@gmail.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756027AbaHGXHZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:07:25 -0400
In-Reply-To: <1407448106-1819-2-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Thu,  7 Aug 2014 23:48:25 +0200

> When the driver attaches to a device that has a phy handle the probe
> routine returns with a reference to that node. This reference is
> correctly dropped in the error path and the remove function. In the
> fixed phy case however no reference is acquired and so the error path
> might drop a reference the driver isn't holding. Fix that by getting =
a
> reference to the MAC.
>=20
> Fixes: 87009814cdbb ("ucc_geth: use the new fixed PHY helpers")
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied.
