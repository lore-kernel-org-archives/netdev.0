From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip6_tunnel: add optional fwmark inherit
Date: Tue, 20 Sep 2011 14:50:14 -0400 (EDT)
Message-ID: <20110920.145014.886551420797359784.davem@davemloft.net>
References: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903109@ESESSCMS0356.eemea.ericsson.se>
	<1316449646.2539.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hans.schillstrom@ericsson.com, netdev@vger.kernel.org,
	Anders.Franzen@ericsson.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752399Ab1ITSuX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 14:50:23 -0400
In-Reply-To: <1316449646.2539.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Sep 2011 18:27:26 +0200

> [PATCH net-next] ip6_tunnel: add optional fwmark inherit
>=20
> Add IP6_TNL_F_USE_ORIG_FWMARK to ip6_tunnel, so that ip6_tnl_xmit2()
> makes a route lookup taking into account skb->fwmark and doesnt cache
> lookup result.
>=20
> This permits more flexibility in policies and firewall setups.
>=20
> To setup such a tunnel, "fwmark inherit" option should be added to "i=
p
> -f inet6 tunnel" command.
>=20
> Reported-by: Anders Franzen <Anders.Franzen@ericsson.com>
> CC: Hans Schillstr=F6m <hans.schillstrom@ericsson.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
