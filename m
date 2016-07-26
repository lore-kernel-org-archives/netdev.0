From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: davinci_cpdma: remove excessive dump of
 register values to kernel log
Date: Mon, 25 Jul 2016 17:57:05 -0700 (PDT)
Message-ID: <20160725.175705.820422537273157170.davem@davemloft.net>
References: <1469440485-19889-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
	linux-omap@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753622AbcGZA5G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 20:57:06 -0400
In-Reply-To: <1469440485-19889-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Mon, 25 Jul 2016 11:54:45 +0200

> Such a big dump of register values is hardly useful on a production
> system.
>=20
> Another downside of the now removed functions is that calling
> emac_dump_regs resulted in at least 87 calls to dev_info while holdin=
g a
> spinlock and having irqs off which is a big source of latency.
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied.
