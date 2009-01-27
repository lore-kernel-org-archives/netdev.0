From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Tue, 27 Jan 2009 23:34:02 +0100
Message-ID: <497F8BDA.6080908@cosmosbay.com>
References: <497E361B.30909@hp.com>	<497E42F4.7080201@cosmosbay.com>	<497E44F6.2010703@hp.com>	<497ECF84.1030308@cosmosbay.com>	<497ED0A2.6050707@trash.net>	<497F350A.9020509@cosmosbay.com>	<497F457F.2050802@trash.net>	<497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com>	<497F5F86.9010101@hp.com> <497F87E7.2000304@cosmosbay.com> <497F8ACD.2050203@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:41512
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751433AbZA0XR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 18:17:28 -0500
In-Reply-To: <497F8ACD.2050203@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones a =E9crit :
>
>> Thanks for the report
>>
>> If you have so much contention on spinlocks, maybe hash function is=20
>> not good at all...
>>
>> hash =3D (unsigned long)ct;
>> hash ^=3D hash >> 16;
>> hash ^=3D hash >> 8;
>>
>> I ass-u-me you compiled your kernel with NR_CPUS=3D32 ?
>
> I believe so - CONFIG_NR_CPUS in .config is 64 anyway.  If there is a=
=20
> more definitive place to check I'd be happy to look.
>
> rick
>
>

By any chance, are you using SLAB instead of SLUB ?

While running your netperf session, issuing :

grep conntrack /proc/slabinfo

Would help to know hash dispertion on your machine.


