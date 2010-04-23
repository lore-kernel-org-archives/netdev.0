From: David Miller <davem@davemloft.net>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 01:13:28 -0700 (PDT)
Message-ID: <20100423.011328.107238355.davem@davemloft.net>
References: <1271970893.7895.6507.camel@edumazet-laptop>
	<20100422.164425.171794554.davem@davemloft.net>
	<1272001478.7895.7545.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hawk@diku.dk, paulmck@linux.vnet.ibm.com, kaber@trash.net,
	xiaosuo@gmail.com, hawk@comx.dk, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1272001478.7895.7545.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 23 Apr 2010 07:44:38 +0200

> Le jeudi 22 avril 2010 =E0 16:44 -0700, David Miller a =E9crit :
>> Eric, I wonder if we run into some kind of issue on 32-bit systems
>> because we always lose a bit of the conntrack hash value when we sto=
re
>> it into the 'nulls' area?
>>=20
>> Wouldn't that make the "get_nulls_value(n) !=3D hash" fail?
>> --
>=20
>=20
> Well, 'hash' at this time is not the result of the jhash() transform =
[0
> - 0xFFFFFFFF], but a slot number in htable [0 - (300032-1)].

Aha, I see.

I really can't see what might cause this behavior then.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
