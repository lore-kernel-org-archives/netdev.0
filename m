From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Bug, kernel panic, NULL dereference , =?UTF-8?Q?cleanup=5Fonc?=  =?UTF-8?Q?e=20/=20icmp=5Froute=5Flookup=2Eclone=2E=31=39=2Eclone=20/=20na?=  =?UTF-8?Q?t=20=2C=20=32=2E=36=2E=33=39-rc=37-git=31=31?=
Date: Wed, 18 May 2011 15:46:07 +0300
Message-ID: <4ae96506c000a4b3c8f78ccef836deaf@visp.net.lb>
References: <54ec5cd14e5e5c76aa06c2e6899299ce@visp.net.lb>
 <41a1892fed59b411bb08d3ecb0d8cda5@visp.net.lb>
 <1305711471.2983.27.camel@edumazet-laptop>
 <0a630bbf006d1210220a6ba4d55c5804@visp.net.lb>
 <1305713111.2991.1.camel@edumazet-laptop>
 <1305719047.2991.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:59515 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S933074Ab1ERMqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 08:46:09 -0400
In-Reply-To: <1305719047.2991.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Wed, 18 May 2011 13:44:07 +0200, Eric Dumazet wrote:
> Le mercredi 18 mai 2011 =C3=A0 12:05 +0200, Eric Dumazet a =C3=A9crit=
 :
>> Le mercredi 18 mai 2011 =C3=A0 12:53 +0300, Denys Fedoryshchenko a =C3=
=A9crit=20
>> :
>>
>> >  Yes, i will try. I should enable SLUB debugging only, or also=20
>> anything
>> >  else?
>> >
>> >  But possible it will take time to reproduce bug, seems it is=20
>> occuring
>> >  rare. With 2.6.39 release i will rollout update to few hundreds=20
>> PPPoE's,
>> >  maybe it will increase chances to get information.
>> >
>>
>> I would try both : slub_debug=3DZFP slub_nomerge
>>
>> or maybe only slub_debug=3DZFPU
>>
>> Thanks !
>>
>
> Hmm, do you have both ipv6/ipv4 trafic on your machine by any chance=20
> ?
 It is NAS, has ipv6 enabled recently (i am preparing for ipv6), but=20
 ipv6 is not routed anywhere, maybe just automatically addresses=20
 appearing on interfaces, including the one looking to customer subnet.=
=20
 ppp is ipv4 only.

