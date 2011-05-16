From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Change netdev_fix_features messages loglevel
Date: Mon, 16 May 2011 15:14:34 -0400 (EDT)
Message-ID: <20110516.151434.829498612745581899.davem@davemloft.net>
References: <20110516131757.ED57E13A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, mst@redhat.com,
	herbert@gondor.hengli.com.au, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146Ab1EPTPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 15:15:47 -0400
In-Reply-To: <20110516131757.ED57E13A6A@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Mon, 16 May 2011 15:17:57 +0200 (CEST)

> Those reduced to DEBUG can possibly be triggered by unprivileged proc=
esses
> and are nothing exceptional. Illegal checksum combinations can only b=
e
> caused by driver bug, so promote those messages to WARN.
>=20
> Since GSO without SG will now only cause DEBUG message from
> netdev_fix_features(), remove the workaround from register_netdevice(=
).
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied, thanks.
