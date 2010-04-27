From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Tue, 27 Apr 2010 15:08:17 -0700 (PDT)
Message-ID: <20100427.150817.84390202.davem@davemloft.net>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	<1272018366.7895.7930.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, hadi@cyberus.ca, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54708
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754553Ab0D0WIL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 18:08:11 -0400
In-Reply-To: <1272018366.7895.7930.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 23 Apr 2010 12:26:06 +0200

> Le vendredi 23 avril 2010 =E0 16:12 +0800, Changli Gao a =E9crit :
>> batch skb dequeueing from softnet input_pkt_queue.
>>=20
>> batch skb dequeueing from softnet input_pkt_queue to reduce potentia=
l lock
>> contention when RPS is enabled.
>>=20
>> Note: in the worst case, the number of packets in a softnet_data may=
 be double
>> of netdev_max_backlog.
>>=20
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ----
>=20
> Oops, reading it again, I found process_backlog() was still taking th=
e
> lock twice, if only one packet is waiting in input_pkt_queue.
>=20
> Possible fix, on top of your patch :

I've applied Changli's patch with this fixup added to it.

If there are any follow-on changes necessary after further analysis,
please send patches on top of this work.

Thanks.
