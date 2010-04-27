From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: set skb->rxhash
Date: Tue, 27 Apr 2010 15:45:32 -0700 (PDT)
Message-ID: <20100427.154532.128588325.davem@davemloft.net>
References: <1272406825-11615-1-git-send-email-dm@chelsio.com>
	<1272408192.2343.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dm@chelsio.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46809
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755114Ab0D0Wp0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 18:45:26 -0400
In-Reply-To: <1272408192.2343.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Apr 2010 00:43:12 +0200

> Le mardi 27 avril 2010 =E0 15:20 -0700, Dimitris Michailidis a =E9cri=
t :
>> Implement the ->set_flags ethtool method to control NETIF_F_RXHASH a=
nd
>> set skb->rxhash to the HW calculated hash accordingly.
>>=20
>> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
>=20
>>  	skb_record_rx_queue(skb, rxq->rspq.idx);
>> +	if (rxq->rspq.netdev->features & NETIF_F_RXHASH)
>> +		skb->rxhash =3D ntohl(pkt->rsshdr.hash_val);
>> =20
>=20
> Its probably minor, but hash_val being a semi random 32bits value, yo=
u
> can avoid the ntohl() conversion, using a (__force u32) cast ...

Agreed.
