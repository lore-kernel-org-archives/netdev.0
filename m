From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: Re: tc action mirred packet lost
Date: Wed, 03 Nov 2010 07:16:08 +0000
Message-ID: <bef3d3cd45067b76a93c6728e077871a@justnet.pl>
References: <aff638d83f21a1b8ab3e1911f2d3ac43@justnet.pl>
 <4CCEA16B.1050603@gmail.com>
Reply-To: adam.niescierowicz@justnet.pl
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.justnet.pl ([80.54.30.237]:44492 "EHLO mail.justnet.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753186Ab0KCHQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Nov 2010 03:16:10 -0400
In-Reply-To: <4CCEA16B.1050603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Mon, 01 Nov 2010 12:15:55 +0100, Jarek Poplawski <jarkao2@gmail.com=
>=20
 wrote:
> Nie=C5=9Bcierowicz Adam wrote:
>> Hello,
>> recently there was a need to create 3-4 copies of the data sent to=20
>> the
>> router, I decided to use the tc action mirred.
>>
>>
>> Ingress traficn on eth1 copies to eth1 eth2, eth3, eth4, eth5 using:
>> ---
>> tc qdisc add dev eth1 ingress
>>
>> tc filter add dev eth1 parent ffff: protocol ip prio 10 u32 match ip=
=20
>> src
>> 0/0 flowid 1:1 action mirred egress mirror dev eth2 pipe action=20
>> mirred
>> egress mirror dev eth3 pipe action mirred egress mirror dev eth4=20
>> pipe
>> action mirred egress mirror dev eth5
>> --
>>
>>
>> Unfortunately the number of packets seen on eth1 qdisc is different=20
>> than
>> the eth [2-5]
>
> Hi,
> Usually the reason for such differences is arp or other non-ip
> protocols. Try a filter with "protocol all" to check this.
>
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

 Thanks, it works


