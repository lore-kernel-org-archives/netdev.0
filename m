From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: e1000: Question about polling
Date: Wed, 20 Feb 2008 12:25:32 +0300
Message-ID: <47BBF20C.1050706@bigtelecom.ru>
References: <20080220075054.GB3885@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:39370 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820AbYBTJZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 04:25:52 -0500
In-Reply-To: <20080220075054.GB3885@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for little information and mistakes in letter. Jesse Brandeburg 
ask for all my questions. In future i will try to be more accurate then 
write letters and post more info.
Please not think that it disrespect for you. Its simple language barrier =(
> On 18-02-2008 10:18, Badalian Vyacheslav wrote:
>   
>> Hello all.
>>     
>
> Hi,
>
>   
>> Interesting think:
>>
>> Have PC that do NAT. Bandwidth about 600 mbs.
>>
>> Have  4 CPU (2xCoRe 2 DUO "HT OFF" 3.2 HZ).
>>
>> irqbalance in kernel is off.
>>
>> nat2 ~ # cat /proc/irq/217/smp_affinity
>> 00000001
>> nat2 ~ # cat /proc/irq/218/smp_affinity
>> 00000003
>>
>> Load SI on CPU0 and CPU1 is about 90%
>>
>> Good... try do
>> echo ffffffff > /proc/irq/217/smp_affinity
>> echo ffffffff > /proc/irq/218/smp_affinity
>>
>> Get 100% SI at CPU0
>>
>> Question Why?
>>     
>
> I think you should show here /proc/interrupts in all these cases.
>
>   
>> I listen that if use IRQ from 1 netdevice to 1 CPU i can get 30% 
>> perfomance... but i have 4 CPU... i must get more perfomance if i cat 
>> "ffffffff"  to smp_affinity.
>>
>> picture looks liks this:
>> 0-3 CPU get over 50% SI.... bandwith up.... 55% SI... bandwith up... 
>> 100% SI on CPU0....
>>
>> I remember patch to fix problem like it... patched function 
>> e1000_clean...  kernel on pc have this patch (2.6.24-rc7-git2)... e1000 
>> driver work much better (i up to 1.5-2x bandwidth before i get 100% SI), 
>> but i think that it not get 100% that it can =)
>>     
>
> If some patch works for you, and you can show here its advantages,
> you should probably add here some link and request for merging.
>
> BTW, I wonder if you tried to check if changing CONFIG_HZ makes any
> difference here?
>
> Regards,
> Jarek P.
>
>   

