From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bonding: factor out rlock(bond->lock) in xmit path
Date: Mon, 09 May 2011 12:06:16 -0700 (PDT)
Message-ID: <20110509.120616.260076504.davem@davemloft.net>
References: <20110507114802.9CE7513A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59451
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751933Ab1EITGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:06:48 -0400
In-Reply-To: <20110507114802.9CE7513A6A@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sat,  7 May 2011 13:48:02 +0200 (CEST)

> Pull read_lock(&bond->lock) and BOND_IS_OK() to bond_start_xmit() fro=
m
> mode-dependent xmit functions.
>=20
> netif_running() is always true in hard_start_xmit.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied, thanks.
