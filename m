From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Thu, 30 Oct 2008 06:51:53 +0100
Message-ID: <49094B79.4010805@cosmosbay.com>
References: <4908C0CD.5050406@cosmosbay.com>	<20081029201759.GF6732@linux.vnet.ibm.com>	<4908DEDE.5030706@cosmosbay.com> <20081029.224027.163185414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, minyard@acm.org, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	cl@linux-foundation.org, a.p.zijlstra@chello.nl,
	johnpol@2ka.mipt.ru, christian@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:38391 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbYJ3Fw2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 01:52:28 -0400
In-Reply-To: <20081029.224027.163185414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 29 Oct 2008 23:08:30 +0100
>=20
>> @@ -1746,7 +1753,7 @@ void __init udp_table_init(struct udp_table *t=
able)
>>  	int i;
>> =20
>>  	for (i =3D 0; i < UDP_HTABLE_SIZE; i++) {
>> -		INIT_HLIST_HEAD(&table->hash[i].head);
>> +		table->hash[i].head.first =3D (struct hlist_node *)i;
>=20
> Please hide this behind some list.h interface macro, even something
> as simple as INIT_HLIST_HEAD_NULLS(X, index) would suffice.
>=20
> And as Corey said, the code needs more comments for something as
> clever as this! :-)
>=20

Yes I agree 100%, please give me one day to prepare a real patch,
or else akpm will kill us :)



