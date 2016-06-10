From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_en: fix ethtool -x
Date: Thu, 09 Jun 2016 23:40:07 -0700 (PDT)
Message-ID: <20160609.234007.1351432057965400024.davem@davemloft.net>
References: <1464267580.5939.83.camel@edumazet-glaptop3.roam.corp.google.com>
	<1464979969.5939.200.camel@edumazet-glaptop3.roam.corp.google.com>
	<1465359858.24873.35.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ttoukan.linux@gmail.com, maze@google.com, edumazet@google.com,
	netdev@vger.kernel.org, willemb@google.com, eugenia@mellanox.com,
	weiwan@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbcFJGkI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 02:40:08 -0400
In-Reply-To: <1465359858.24873.35.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Jun 2016 21:24:18 -0700

> From: Eric Dumazet <edumazet@google.com>
>=20
> mlx4 RSS is limited to spread incoming packets to a power of two numb=
er
> of queues.
>=20
> An uniformly distibuted traffic would be split on queues 0 to N-1, N
> being a power of two, each queue having a 1/N weight.
>=20
> If number of RX queues is not a power of two, upper RX queues do not
> receive traffic.
>=20
> ethtool -x is lying, because it pretends some queues have higher weig=
ht.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Maciej =AFenczykowski <maze@google.com>

Applied.
