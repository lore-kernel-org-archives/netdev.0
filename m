From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] ipv4: properly refresh rtable entries on
 pmtu/redirect events
Date: Mon, 03 Jun 2013 00:09:57 -0700 (PDT)
Message-ID: <20130603.000957.1597052548574442658.davem@davemloft.net>
References: <20130527.233844.2081972819091665848.davem@davemloft.net>
	<1369723593-5307-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37911 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab3FCHJ6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:09:58 -0400
In-Reply-To: <1369723593-5307-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Tue, 28 May 2013 09:46:31 +0300

> This reverts commit 05ab86c5 (xfrm4: Invalidate all ipv4 routes on
> IPsec pmtu events). Flushing all cached entries is not needed.
>=20
> Instead, invalidate only the related next hop dsts to recheck for
> the added next hop exception where needed. This also fixes a subtle
> race due to bumping generation id's before updating the pmtu.
>=20
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Applied.
