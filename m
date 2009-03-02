From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] iptables: lock free counters
Date: Mon, 2 Mar 2009 14:17:30 -0800
Message-ID: <20090302221730.GJ6712@linux.vnet.ibm.com>
References: <20090218051906.174295181@vyatta.com> <20090218052747.321329022@vyatta.com> <20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com> <49A7F262.8040805@cosmosbay.com> <49ABBB21.9080401@trash.net> <49AC1B9D.5030107@cosmosbay.com> <49AC5617.8020404@trash.net> <20090302140243.3aad4d5b@nehalam> <49AC5896.1010400@trash.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:35074 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbZCBWRd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 17:17:33 -0500
Content-Disposition: inline
In-Reply-To: <49AC5896.1010400@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 02, 2009 at 11:07:18PM +0100, Patrick McHardy wrote:
> Stephen Hemminger wrote:
>> On Mon, 02 Mar 2009 22:56:39 +0100
>> Patrick McHardy <kaber@trash.net> wrote:
>>> Eric Dumazet wrote:
>>>> Patrick McHardy a =E9crit :
>>>>> Eric Dumazet wrote:
>>>>>> real    0m1.810s
>>>>>> user    0m0.000s
>>>>>> sys     0m0.001s
>>>>> Thats really slow ...
>>>>>
>>>>>> CONFIG_NO_HZ=3Dy
>>>>>> CONFIG_HZ_1000=3Dy
>>>>>> CONFIG_HZ=3D1000
>>>>>>
>>>>>> One cpu is 100% handling softirqs, could it be the problem ?
>>>>> Is this fixed by your RCU quiescent state fix?
>>>> Yes it is :)
>>> Great, thanks :)
>> I wonder if the RCU quiescent fix should go in 2.6.29 because it
>> fixes other issues like route changing RCU latency under Dos attack.
>
> From what I can tell, it should.

I agree.

							Thanx, Paul
