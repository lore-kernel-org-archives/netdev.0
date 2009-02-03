From: Kenny Chang <kchang@athenacr.com>
Subject: Re: Multicast packet loss
Date: Tue, 03 Feb 2009 10:20:13 -0500
Message-ID: <498860AD.5010702@athenacr.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <20090131160333.GC23100@localhost.localdomain> <498723D9.5020509@athenacr.com> <20090203115502.GB28117@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.95.46.209] ([64.95.46.209]:1125 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752280AbZBCPUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 10:20:19 -0500
Received: from [192.168.14.21] (fiji.em.in.athenacr.com [192.168.14.21])
	by sprinkles.inp.in.athenacr.com (Postfix) with ESMTP id CC26B4B921
	for <netdev@vger.kernel.org>; Tue,  3 Feb 2009 10:20:15 -0500 (EST)
In-Reply-To: <20090203115502.GB28117@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:
> On Mon, Feb 02, 2009 at 11:48:25AM -0500, Kenny Chang wrote:
>  =20
>> Neil Horman wrote:
>>    =20
>>> On Fri, Jan 30, 2009 at 11:41:23PM +0100, Eric Dumazet wrote:
>>>  =20
>>>      =20
>>>> Kenny Chang a =E9crit :
>>>>    =20
>>>>        =20
>>>>> Ah, sorry, here's the test program attached.
>>>>>
>>>>> We've tried 2.6.28.1, but no, we haven't tried the 2.6.28.2 or th=
e
>>>>> 2.6.29.-rcX.
>>>>>
>>>>> Right now, we are trying to step through the kernel versions unti=
l we
>>>>> see where the performance drops significantly.  We'll try 2.6.29-=
rc soon
>>>>> and post the result.
>>>>>      =20
>>>>>          =20
>>>> 2.6.29-rc contains UDP receive improvements (lockless)
>>>>
>>>> Problem is multicast handling was not yet updated, but could be :)
>>>>
>>>>
>>>> I was asking you "cat /proc/interrupts" because I believe you migh=
t
>>>> have a problem NIC interrupts being handled by one CPU only (when =
having problems)
>>>>
>>>>    =20
>>>>        =20
>>> That would be expected (if irqbalance is running), and desireable, =
since
>>> spreading high volume interrupts like NICS accross multiple cores (=
or more
>>> specifically multiple L2 caches), is going increase your cache line=
 miss rate
>>> significantly and decrease rx throughput.
>>>
>>> Although you do have a point here, if the system isn't running irqb=
alance, and
>>> the NICS irq affinity is spread accross multiple L2 caches, that wo=
uld be a
>>> point of improvement performance-wise. =20
>>>
>>> Kenny, if you could provide the /proc/interrupts info along with /p=
roc/cpuinfo
>>> and your stats that I asked about earlier, that would be a big help=
=2E
>>>
>>> Regards
>>> Neil
>>>
>>>  =20
>>>      =20
>> This is for a working setup.
>>
>>    =20
>
> Are these quad core systems?  Or dual core w/ hyperthreading?  I ask =
because in
> your working setup you have 1/2 the number of cpus' and was not sure =
if you
> removed an entire package of if you just disabled hyperthreading.
>
>
> Neil
>
>  =20
Yeah, these are quad core systems.  The 8 cpu system is a dual-processo=
r=20
quad-core.  The other is my desktop, single cpu quad core.

Kenny

