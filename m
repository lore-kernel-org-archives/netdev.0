From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Multicast packet loss
Date: Tue, 3 Feb 2009 06:55:02 -0500
Message-ID: <20090203115502.GB28117@hmsreliant.think-freely.org>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <20090131160333.GC23100@localhost.localdomain> <498723D9.5020509@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kenny Chang <kchang@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50197 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655AbZBCLzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 06:55:12 -0500
Content-Disposition: inline
In-Reply-To: <498723D9.5020509@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 02, 2009 at 11:48:25AM -0500, Kenny Chang wrote:
> Neil Horman wrote:
>> On Fri, Jan 30, 2009 at 11:41:23PM +0100, Eric Dumazet wrote:
>>  =20
>>> Kenny Chang a =E9crit :
>>>    =20
>>>> Ah, sorry, here's the test program attached.
>>>>
>>>> We've tried 2.6.28.1, but no, we haven't tried the 2.6.28.2 or the
>>>> 2.6.29.-rcX.
>>>>
>>>> Right now, we are trying to step through the kernel versions until=
 we
>>>> see where the performance drops significantly.  We'll try 2.6.29-r=
c soon
>>>> and post the result.
>>>>      =20
>>> 2.6.29-rc contains UDP receive improvements (lockless)
>>>
>>> Problem is multicast handling was not yet updated, but could be :)
>>>
>>>
>>> I was asking you "cat /proc/interrupts" because I believe you might
>>> have a problem NIC interrupts being handled by one CPU only (when h=
aving problems)
>>>
>>>    =20
>> That would be expected (if irqbalance is running), and desireable, s=
ince
>> spreading high volume interrupts like NICS accross multiple cores (o=
r more
>> specifically multiple L2 caches), is going increase your cache line =
miss rate
>> significantly and decrease rx throughput.
>>
>> Although you do have a point here, if the system isn't running irqba=
lance, and
>> the NICS irq affinity is spread accross multiple L2 caches, that wou=
ld be a
>> point of improvement performance-wise. =20
>>
>> Kenny, if you could provide the /proc/interrupts info along with /pr=
oc/cpuinfo
>> and your stats that I asked about earlier, that would be a big help.
>>
>> Regards
>> Neil
>>
>>  =20
> This is for a working setup.
>

Are these quad core systems?  Or dual core w/ hyperthreading?  I ask be=
cause in
your working setup you have 1/2 the number of cpus' and was not sure if=
 you
removed an entire package of if you just disabled hyperthreading.


Neil

