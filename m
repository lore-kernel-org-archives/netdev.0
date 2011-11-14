From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: introduce build_skb()
Date: Mon, 14 Nov 2011 14:29:16 -0500 (EST)
Message-ID: <20111114.142916.2005300491189237669.davem@davemloft.net>
References: <1321286614.2272.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111114.142153.804127798975712263.davem@davemloft.net>
	<1321298766.2719.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eilong@broadcom.com, pstaszewski@itcare.pl, netdev@vger.kernel.org,
	bhutchings@solarflare.com, therbert@google.com, hadi@mojatatu.com,
	shemminger@vyatta.com, tgraf@infradead.org,
	herbert@gondor.hengli.com.au, jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367Ab1KNTae convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:30:34 -0500
In-Reply-To: <1321298766.2719.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Nov 2011 20:26:06 +0100

> Le lundi 14 novembre 2011 =E0 14:21 -0500, David Miller a =E9crit :
>=20
>> Applied, I'll work on converting NIU over to this if I find some tim=
e.
>=20
> I dont believe NIU needs it, since its a frag enabled driver.
>=20
> You already allocate a fresh skb (and attach frags to it) right befor=
e
> giving it to upper stack.

Oh I see, this is for drivers which splat the packet into a linear
buffer to begin with.
