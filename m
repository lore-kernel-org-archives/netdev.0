From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: add skb.old_queue_mapping
Date: Mon, 13 Dec 2010 09:58:47 -0800 (PST)
Message-ID: <20101213.095847.104075355.davem@davemloft.net>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
	<1292251414-5154-5-git-send-email-xiaosuo@gmail.com>
	<1292259412.2759.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37403
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756546Ab0LMR6T convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 12:58:19 -0500
In-Reply-To: <1292259412.2759.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 13 Dec 2010 17:56:52 +0100

> Le lundi 13 d=E9cembre 2010 =E0 22:43 +0800, Changli Gao a =E9crit :
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 19f37a6..2ce2a96 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -403,6 +403,9 @@ struct sk_buff {
>>  	};
>> =20
>>  	__u16			vlan_tci;
>> +#ifdef CONFIG_NET_CLS_ACT
>> +	__u16			old_queue_mapping;
>> +#endif
>> =20
>=20
> Are you sure we need this field here ? Why not using cb[] for example=
 ?

Agreed, we should be removing sk_buff members not adding new ones.

We should especially not be adding new members to this critical
structure for more obscure facilities like ifb.
