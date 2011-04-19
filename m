From: Michal Simek <monstr@monstr.eu>
Subject: Re: Hight speed data sending from custom IP out of kernel
Date: Tue, 19 Apr 2011 13:50:09 +0200
Message-ID: <4DAD76F1.40309@monstr.eu>
References: <53f539ea861e1a24bde4aadceff0b3bb.squirrel@www.liukuma.net>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: juice@swagman.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33207 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184Ab1DSLuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 07:50:16 -0400
Received: by fxm17 with SMTP id 17so3318182fxm.19
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 04:50:12 -0700 (PDT)
In-Reply-To: <53f539ea861e1a24bde4aadceff0b3bb.squirrel@www.liukuma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Juice,

juice wrote:
> Hi Michal.
> 
> How fast do you need to send the data?

It sounds weird but as fast as possible. There is no specific limit because I 
want to create demo and test it on various hw configuration which I can easily 
create on FPGA. For now the bottleneck is Microblaze cpu. It can run from 50MHz 
till 170-180MHz. We also support both endians and have two hw IP 
cores(10/100/1000) which I can use.

> I have an application where I send test stream out to GE line and can fill
> the total capacity of the ethernet regardless of the packet size.

What cpu do you use?

> 
> The test stream I am sending is stored in kernel memory, and therefore is
> limited by the amount of free memory. 200M is no problem.

Is it UDP or TCP?

> 
> The solution I am using is loosely based on the pktgen module, except that
> my module can load a wireshark capture from userland program and then send
> it from ethernet interface in wire speed.

Sound good. Would it be possible to see it and test it?

Thanks,
Michal


> 
>   - Juice -
> 
> 
>> Hi,
>> I would like to create demo for high speed data sending from custom IP
> through
>> the ethernet. I think the best description is that there are dmaable memory
>> mapped registers or just memory which store data I want to send (for
> example 200MB).
>> Linux should handle all communication between target(probably server)
> and
>> host
>> (client) but data in the packets should go from that custom IP and can't go
>> through the kernel because of performance issue.
>> Ethernet core have own DMA which I could use but the question is if
> there
>> is any
>> option how to convince the kernel that data will go directly from memory
> mapped
>> registers and the kernel/driver/... just setup dma BD for headers and
> second for
>> data.
>> Do you have any experience with any solution with passing data
> completely
>> out of
>> kernel?
>> Thanks,
>> Michal
>> --
>> Michal Simek, Ing. (M.Eng)
>> w: www.monstr.eu p: +42-0-721842854
>> Maintainer of Linux kernel 2.6 Microblaze Linux -
>> http://www.monstr.eu/fdt/
>> Microblaze U-BOOT custodian
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 
> 


-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
