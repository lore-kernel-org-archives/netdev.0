From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key
Date: Wed, 6 Jan 2016 14:32:33 +0800
Message-ID: <568CB501.1010106@oracle.com>
References: <1452059368-7527-1-git-send-email-wen.gang.wang@oracle.com>
 <20160106.011835.39198953316515142.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45439 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbcAFG3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 01:29:09 -0500
In-Reply-To: <20160106.011835.39198953316515142.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=E5=9C=A8 2016=E5=B9=B401=E6=9C=8806=E6=97=A5 14:18, David Miller =E5=86=
=99=E9=81=93:
> From: Wengang Wang <wen.gang.wang@oracle.com>
> Date: Wed,  6 Jan 2016 13:49:28 +0800
>
>> @@ -523,11 +523,20 @@ static void build_skb_flow_key(struct flowi4 *=
fl4, const struct sk_buff *skb,
>>   			       const struct sock *sk)
>>   {
>>   	const struct iphdr *iph =3D ip_hdr(skb);
>> -	int oif =3D skb->dev->ifindex;
>> +	int oif;
>> +	struct net_device *master =3D NULL;
>> +
>>   	u8 tos =3D RT_TOS(iph->tos);
>>   	u8 prot =3D iph->protocol;
>>   	u32 mark =3D skb->mark;
>>  =20
> Please fix the stlye of these variable declarations:
>
> 1) Order them from longest line to shortest line, also known
>     as "reverse christmas tree" layout.
>
> 2) Do not add an empty line in the middle of these variable
>     declarations.
OK, will do in second drop.

thanks,
wengang
