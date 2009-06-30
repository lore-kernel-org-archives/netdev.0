From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: weird problem
Date: Tue, 30 Jun 2009 10:35:16 +0200
Message-ID: <4A49CE44.6030001@itcare.pl>
References: <20090630064022.GA5589@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:52130 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045AbZF3IfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2009 04:35:16 -0400
In-Reply-To: <20090630064022.GA5589@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski pisze:
> On 26-06-2009 19:45, Pawe. Staszewski wrote:
>   
>> Eric Dumazet pisze:
>>     
> ...
>   
>>> Pawel made some reports errors in fib thread, so I am not sure he really
>>>  tried 2.6.30 and had same oprofile results.
>>>
>>> rt_worker_func() taking 13% of cpu0 is an alarm for me :)
>>> And 21% of cpu0 and 34% of cpu6 taken by oprofiled seems odd too...
>>>
>>> Pawel, could you give us :
>>>
>>> grep . /proc/sys/net/ipv4/route/*
>>> cat /proc/interrupts
>>>
>>> on your various kernels (previous to 2.6.29, 2.6.29, 2.6.30, ...)
>>>
>>> I suspect a change in hash table size, and/or change in interrupt affinities...
>>>       
>
> Btw., Pawel these eth0's don't look like affined or I miss something?
>
> Jarek P.
> ...
>   
>> cat /proc/interrupts
>>            CPU0       CPU1       CPU2       CPU3       CPU4       
>> CPU5       CPU6       CPU7
>>     
> ...
>   
>>  29:    1139988   18351004      89662          3          0          
>> 1          0          3   PCI-MSI-edge      eth0
>>  30:          0          2   20221692          1          0          
>> 3          0          0   PCI-MSI-edge      eth1
>>     
> ...
>   
Yes
it don't look because i switch a little later after some seconds with 
traffic on this host

Cpu1 - 18351004 interrupts on eth0 (and yes here i forgot to change on boot so there are some interrupts cpu0 1139988 / cpu2 89662)
Cpu2 - 20221692 interrupts on eth1


in attached file are new stats with more counters from /cat /proc/interrupts



>> second machine:
>> Linux TM_02_C1 2.6.30 #1 SMP Thu Jun 25 21:49:58 CEST 2009 i686 Intel(R) 
>> Xeon(R) CPU 3075 @ 2.66GHz GenuineIntel GNU/Linux
>>
>> cat /proc/interrupts
>>            CPU0       CPU1
>>     
> ...
>   
>>  28:      13482      11260   PCI-MSI-edge      eth2
>>  29:          3 1326457765   PCI-MSI-edge      eth1
>>  30: 1240943198  137973134   PCI-MSI-edge      eth0
>>     
>
>
>   

