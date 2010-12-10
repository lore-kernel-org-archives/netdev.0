From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] net/ipv6/udp.c: fix typo in flush_stack()
Date: Fri, 10 Dec 2010 14:05:32 -0800 (PST)
Message-ID: <20101210.140532.191415618.davem@davemloft.net>
References: <20101209134029.GB2820@psychotron.brq.redhat.com>
	<1291902488.4063.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jpirko@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42043
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755858Ab0LJWFE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 17:05:04 -0500
In-Reply-To: <1291902488.4063.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Dec 2010 14:48:08 +0100

> Le jeudi 09 d=E9cembre 2010 =E0 14:40 +0100, Jiri Pirko a =E9crit :
>> skb1 should be passed as parameter to sk_rcvqueues_full() here.
>>=20
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>=20
>> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
>> index 91def93..d2b268e 100644
>> --- a/net/ipv6/udp.c
>> +++ b/net/ipv6/udp.c
>> @@ -602,7 +602,7 @@ static void flush_stack(struct sock **stack, uns=
igned int count,
>> =20
>>  		sk =3D stack[i];
>>  		if (skb1) {
>> -			if (sk_rcvqueues_full(sk, skb)) {
>> +			if (sk_rcvqueues_full(sk, skb1)) {
>>  				kfree_skb(skb1);
>>  				goto drop;
>>  			}
>=20
> net-2.6 ? Its the same truesize anyway...
>=20
> So it's not a bug, but a cosmetic change.
> (I am ok with it, but for net-next-2.6)

Agreed, applied to net-next-2.6, thanks.
