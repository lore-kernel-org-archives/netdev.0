From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: latest netdev net-next kernel panic
Date: Fri, 8 Sep 2017 00:38:50 +0200
Message-ID: <8ae3175c-272c-decf-3b6e-014d67638b23@itcare.pl>
References: <9f4c89c9-1a1b-39ec-6d8c-2c9e4c15911a@itcare.pl>
 <1504820388.15310.71.camel@edumazet-glaptop3.roam.corp.google.com>
 <2e7d813e-0ee9-ede6-7e0e-db2814b3cf94@itcare.pl>
 <91ae50fc-300a-2b92-7de0-ae512f364280@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:33160 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755564AbdIGWk4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 18:40:56 -0400
In-Reply-To: <91ae50fc-300a-2b92-7de0-ae512f364280@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What is weird - changed in bios and enabled p-states and no panic from 
30 minutes

w
  00:38:07 up 33 min,  2 users,  load average: 0.10, 0.13, 0.17
USER     TTY        LOGIN@   IDLE   JCPU   PCPU WHAT

So the problem can be related to some cpu weird stuff with c/p states or 
it is random.



W dniu 2017-09-08 o 00:08, Paweł Staszewski pisze:
> Also this panic occured about 3 minutes after traffic rise to 40G
>
> before host was working without trafic for about 30minutes - after 
> traffic start to flow this bug start.
>
> Now i have this host without traffic and it is working for almost 1 
> hour :)
>
>
>
> W dniu 2017-09-07 o 23:47, Paweł Staszewski pisze:
>> Hi Eric
>>
>>
>> today upgraded some host from 4.13.0-rc7+ to latest net-next from git
>>
>> and run some tests simulate clients traffic 40Gbit / 5Mpps mixed tcp 
>> + udp
>>
>> There is also bgpd running that feeds FIB with full bgp feed - about 
>> 700k prefixes (so routing tables is about 700k routes with about 300 
>> nexthops)
>>
>>
>> There is also simulated about 1000 ip neigh hosts (arp) with about 
>> 300 ip interfaces assigned on vlans
>>
>>
>>
>> With kernel 4.13.0-rc7+ (git from 05.09.2017) all tests are good 
>> (besides that there is panic after about 10 hours - every time same 
>> like in this link:
>>
>> https://bugzilla.kernel.org/attachment.cgi?id=258257
>>
>> But looks like acpi related or c/p states with new intel cpus... dono 
>> now.
>>
>>
>>
>>
>> W dniu 2017-09-07 o 23:39, Eric Dumazet pisze:
>>> On Thu, 2017-09-07 at 23:30 +0200, Paweł Staszewski wrote:
>>>> I want to mention also here cause last trace for RIP was dst_dev_put
>>>>
>>>> https://bugzilla.kernel.org/attachment.cgi?id=258259
>>> Can you provide a bit more context ?
>>>
>>> Thanks !
>>>
>>>
>>>
>>
>>
>
>
