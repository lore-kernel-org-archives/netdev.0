From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: timestamp cloned packet in
 dev_queue_xmit_nit
Date: Tue, 21 Dec 2010 10:50:43 -0800 (PST)
Message-ID: <20101221.105043.226759798.davem@davemloft.net>
References: <1292577988.2906.1.camel@edumazet-laptop>
	<1292916171.2627.184.camel@edumazet-laptop>
	<AANLkTin6pzkUAcmH12ywTsRAABEKch9=iHziZ0oURZYd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	jarkao2@gmail.com
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56334
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752709Ab0LUSuO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 13:50:14 -0500
In-Reply-To: <AANLkTin6pzkUAcmH12ywTsRAABEKch9=iHziZ0oURZYd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Changli Gao <xiaosuo@gmail.com>
Date: Tue, 21 Dec 2010 15:56:17 +0800

> On Tue, Dec 21, 2010 at 3:22 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> Le vendredi 17 d=E9cembre 2010 =E0 10:26 +0100, Eric Dumazet a =E9cr=
it :
>> [PATCH net-next-2.6] net: timestamp cloned packet in dev_queue_xmit_=
nit
>>
>> Now we do one clone of skb if at least one sniffer might take packet=
,
>> we also can do the skb timestamping on the clone and let original pa=
cket
>> unchanged.
>>
>> This is a generalization of commit 8caf153974f2 (net: sch_netem: Fix=
 an
>> inconsistency in ingress netem timestamps.)
>>
>> This way, we can have a good idea when packets are delivered to our
>> stack (tcpdump -i ifb0), while a tcpdump on original device gives
>> timestamps right before ingressing.
>>
>> This also speedup our stack, avoiding taking timestamps if not neede=
d.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Changli Gao <xiaosuo@gmail.com>
>> Cc: Patrick McHardy <kaber@trash.net>
>> Cc: Jarek Poplawski <jarkao2@gmail.com>
>=20
> Acked-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks.
