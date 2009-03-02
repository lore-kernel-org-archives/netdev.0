From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] iptables: lock free counters
Date: Mon, 02 Mar 2009 18:47:09 +0100
Message-ID: <49AC1B9D.5030107@cosmosbay.com>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.321329022@vyatta.com> <20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com> <49A7F262.8040805@cosmosbay.com> <49ABBB21.9080401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33087 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbZCBRr2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 12:47:28 -0500
In-Reply-To: <49ABBB21.9080401@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> # time iptables -nvL
>> Chain INPUT (policy ACCEPT 416M packets, 64G bytes)
>>  pkts bytes target     prot opt in     out     source             =20
>> destination
>>
>> Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
>>  pkts bytes target     prot opt in     out     source             =20
>> destination
>>
>> Chain OUTPUT (policy ACCEPT 401M packets, 62G bytes)
>>  pkts bytes target     prot opt in     out     source             =20
>> destination
>>
>> real    0m1.810s
>> user    0m0.000s
>> sys     0m0.001s
>=20
> Thats really slow ...
>=20
>> CONFIG_NO_HZ=3Dy
>> CONFIG_HZ_1000=3Dy
>> CONFIG_HZ=3D1000
>>
>> One cpu is 100% handling softirqs, could it be the problem ?
>=20
> Is this fixed by your RCU quiescent state fix?

Yes it is :)

