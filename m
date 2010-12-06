From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Fix too optimistic NETIF_F_HW_CSUM features
Date: Mon, 06 Dec 2010 13:01:56 -0800 (PST)
Message-ID: <20101206.130156.245409429.davem@davemloft.net>
References: <20101130142352.3936.51663.stgit@rechot.qmqm.pl>
	<20101130163057.29978.92721.stgit@rechot.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	jesse@nicira.com, jon.mason@exar.com, Ramkrishna.Vepa@exar.com,
	Sivakumar.Subramani@exar.com, Sreenivasa.Honnur@exar.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57673
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753770Ab0LFVB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:01:29 -0500
In-Reply-To: <20101130163057.29978.92721.stgit@rechot.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 30 Nov 2010 17:38:00 +0100 (CET)

> NETIF_F_HW_CSUM is a superset of NETIF_F_IP_CSUM+NETIF_F_IPV6_CSUM, b=
ut
> some drivers miss the difference. Fix this and also fix UFO dependenc=
y
> on checksumming offload as it makes the same mistake in assumptions.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
