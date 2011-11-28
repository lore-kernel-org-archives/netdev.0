From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_sendmsg() wrong access to
 sk_route_caps
Date: Mon, 28 Nov 2011 18:58:40 -0500 (EST)
Message-ID: <20111128.185840.2149356770304852693.davem@davemloft.net>
References: <1322476067.2292.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, mirq-linux@rere.qmqm.pl
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247Ab1K1X7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 18:59:50 -0500
In-Reply-To: <1322476067.2292.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Nov 2011 11:27:47 +0100

> Now sk_route_caps is u64, its dangerous to use an integer to store
> result of an AND operator. It wont work if NETIF_F_SG is moved on the
> upper part of u64.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied, thanks Eric.
