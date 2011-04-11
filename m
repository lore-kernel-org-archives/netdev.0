From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: convert to hw_features
Date: Sun, 10 Apr 2011 18:56:10 -0700 (PDT)
Message-ID: <20110410.185610.28810424.davem@davemloft.net>
References: <20110409124655.A015B13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42681
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753742Ab1DKB4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2011 21:56:46 -0400
In-Reply-To: <20110409124655.A015B13909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sat,  9 Apr 2011 14:46:55 +0200 (CEST)

> This also removes TSO as it's made fully in software --- better to le=
ave this
> to networking core.
>=20
> If the MAC features can be detected at probe time and not at open, th=
en
> stmmac_fix_features could be simplified by limiting hw_features. That=
's
> also better for users as they don't see offloads being togglable but
> never turned on.
>=20
> Redundant fallbacks for TX csum are removed as it's already handled
> by network core.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
