From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: add a salt to mc_hash()
Date: Fri, 08 Feb 2013 17:57:36 -0500 (EST)
Message-ID: <20130208.175736.1569565810949513617.davem@davemloft.net>
References: <1360291262.28557.89.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757385Ab3BHW5h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 17:57:37 -0500
In-Reply-To: <1360291262.28557.89.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Feb 2013 18:41:02 -0800

> From: Eric Dumazet <edumazet@google.com>
>=20
> Some multicast addresses are common to all macvlans,
> so if a multicast message has a hash value collision, we
> have to deliver a copy to all macvlans, adding significant
> latency and possible packet drops if netdev_max_backlog
> limit is hit.
>=20
> Having a per macvlan hash function permits to reduce the
> impact of hash collisions.
>=20
> Suggested-by: Maciej =AFenczykowski <maze@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
