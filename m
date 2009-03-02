From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] iptables: lock free counters
Date: Mon, 02 Mar 2009 23:27:46 +0100
Message-ID: <49AC5D62.5030709@cosmosbay.com>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.321329022@vyatta.com>	<20090219114719.560999b5@extreme>	<499DEF49.3040602@cosmosbay.com>	<49A7F262.8040805@cosmosbay.com>	<49ABBB21.9080401@trash.net>	<49AC1B9D.5030107@cosmosbay.com>	<49AC5617.8020404@trash.net> <20090302140243.3aad4d5b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090302140243.3aad4d5b@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =C3=A9crit :
> On Mon, 02 Mar 2009 22:56:39 +0100
> Patrick McHardy <kaber@trash.net> wrote:
>=20
>> Eric Dumazet wrote:
>>> Patrick McHardy a =C3=A9crit :
>>>> Eric Dumazet wrote:
>>>>> real    0m1.810s
>>>>> user    0m0.000s
>>>>> sys     0m0.001s
>>>> Thats really slow ...
>>>>
>>>>> CONFIG_NO_HZ=3Dy
>>>>> CONFIG_HZ_1000=3Dy
>>>>> CONFIG_HZ=3D1000
>>>>>
>>>>> One cpu is 100% handling softirqs, could it be the problem ?
>>>> Is this fixed by your RCU quiescent state fix?
>>> Yes it is :)
>> Great, thanks :)
>=20
> I wonder if the RCU quiescent fix should go in 2.6.29 because it
> fixes other issues like route changing RCU latency under Dos attack.
>=20
>=20

Yes probably, and on stable versions too, since this problem is quite o=
ld...

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
