From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iptables: lock free counters
Date: Mon, 02 Mar 2009 22:56:39 +0100
Message-ID: <49AC5617.8020404@trash.net>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.321329022@vyatta.com> <20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com> <49A7F262.8040805@cosmosbay.com> <49ABBB21.9080401@trash.net> <49AC1B9D.5030107@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55290 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752870AbZCBV4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 16:56:44 -0500
In-Reply-To: <49AC1B9D.5030107@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>> Eric Dumazet wrote:
>>> real    0m1.810s
>>> user    0m0.000s
>>> sys     0m0.001s
>> Thats really slow ...
>>
>>> CONFIG_NO_HZ=3Dy
>>> CONFIG_HZ_1000=3Dy
>>> CONFIG_HZ=3D1000
>>>
>>> One cpu is 100% handling softirqs, could it be the problem ?
>> Is this fixed by your RCU quiescent state fix?
>=20
> Yes it is :)

Great, thanks :)
