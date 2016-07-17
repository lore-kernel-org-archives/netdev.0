From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cpsw: make TI_CPSW_PHY_SEL invisible
Date: Sat, 16 Jul 2016 21:27:55 -0700 (PDT)
Message-ID: <20160716.212755.368973319345221513.davem@davemloft.net>
References: <1468570335-16305-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbcGQE17 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 00:27:59 -0400
In-Reply-To: <1468570335-16305-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Fri, 15 Jul 2016 10:12:15 +0200

> TI_CPSW_PHY_SEL depended on TI_CPSW and was selected by the latter. S=
o
> there is no reason to have this symbol visible.
>=20
> A further optimisation would be to put the code for both symbols into=
 a
> single module which would allow to not export at least cpsw_phy_sel()
> and simplify the module load process.
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied to net-next, thanks.
