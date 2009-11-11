From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] [next-next-2.6] net: configurable device name hash
Date: Wed, 11 Nov 2009 21:08:31 +0100
Message-ID: <4AFB19BF.9060901@gmail.com>
References: <200911112116.14103.opurdila@ixiacom.com> <20091111.112120.134023270.davem@davemloft.net> <200911112138.44074.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38301 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000AbZKKUId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 15:08:33 -0500
In-Reply-To: <200911112138.44074.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> On Wednesday 11 November 2009 21:21:20 you wrote:
>> From: Octavian Purdila <opurdila@ixiacom.com>
>> Date: Wed, 11 Nov 2009 21:16:14 +0200
>>
>>> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
>> We're not doing this sorry.
>>
>> Dynamically size it at boot time or something, but a config
>> option is out of the question.
>>
>=20
> I don't think we can dynamically size it at boot time since it depend=
s on the=20
> usage pattern which is impossible to determine at boot time, right?
>=20
> Would it be acceptable to grow it at runtime, in list_netdevice for i=
nstance?

It will be really hard, now we use RCU lookups...

What workload could reasonably need 1.000.000 hash slots, and 16.000.00=
0 netdevices ?


