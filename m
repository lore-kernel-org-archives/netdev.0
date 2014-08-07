From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: ucc_geth: drop acquired references in probe
 error path and remove
Date: Thu, 07 Aug 2014 16:07:19 -0700 (PDT)
Message-ID: <20140807.160719.1981028891400963453.davem@davemloft.net>
References: <1407448106-1819-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: leoli@freescale.com, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, kernel@pengutronix.de, f.fainelli@gmail.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755322AbaHGXHU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:07:20 -0400
In-Reply-To: <1407448106-1819-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Thu,  7 Aug 2014 23:48:24 +0200

> The ucc_geth_probe function assigns to ug_info->tbi_node and
> ug_info->phy_node a value returned by of_parse_phandle which returns =
a
> new reference. Put this reference again in the error path of
> ucc_geth_probe and when removing the device.
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied.
