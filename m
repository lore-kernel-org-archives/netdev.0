From: Alan Carvalho de Assis <acassis@gmail.com>
Subject: Re: [PATCH] i.MX31: Fixing cs89x0 network building to i.MX31ADS
Date: Tue, 7 Apr 2009 10:52:50 -0300
Message-ID: <37367b3a0904070652w48d2e269xf1e4b2cf88058a1d@mail.gmail.com>
References: <37367b3a0903241018h7ff3302fi83cf1fcb21a3114d@mail.gmail.com>
	 <37367b3a0903300714g40a108d3j59a3b56ee9cda2bf@mail.gmail.com>
	 <20090330143155.GA20101@pengutronix.de>
	 <37367b3a0903301315u51787ebcl119ed295e373a1e4@mail.gmail.com>
	 <20090331075951.GF22913@pengutronix.de>
	 <37367b3a0903310636x3c8d8eban4310018c3d1b40b@mail.gmail.com>
	 <155d92380904010454l34c57687j67e6805dafcb92ef@mail.gmail.com>
	 <37367b3a0904010704o34aa5532p4bc8b3c9a8c16f7f@mail.gmail.com>
	 <155d92380904020508vffc0480j3973973fd4e97fce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>
To: Sajith P V <sajithpv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f160.google.com ([209.85.217.160]:51969 "EHLO
	mail-gx0-f160.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754426AbZDGNwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 09:52:51 -0400
Received: by gxk4 with SMTP id 4so5791542gxk.13
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2009 06:52:50 -0700 (PDT)
In-Reply-To: <155d92380904020508vffc0480j3973973fd4e97fce@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sajith,

On 4/2/09, Sajith P V <sajithpv@gmail.com> wrote:
> Hi Alan
>
> On Wed, Apr 1, 2009 at 7:34 PM, Alan Carvalho de Assis
> <acassis@gmail.com> wrote:
>> It is strange, here I got a similar message:
>> cs89x0:cs89x0_probe(0x0)
>> cs89x0.c: v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew Morton
>> eth0: cs8900 rev K found at 0xf4020300 [Cirrus EEPROM]
>> cs89x0 media RJ-45, IRQ 168, programmed I/O, MAC 00:04:9f:00:41:87
>> cs89x0_probe1() successful
>> cs89x0:cs89x0_probe(0x0)
>> cs89x0: request_region(0xf4020300, 0x10) failed
>> cs89x0: no cs8900 or cs8920 detected.  Be sure to disable PnP with SETUP
>>
>> But network works fine:
>> $ ping 10.29.240.182
>> PING 10.29.240.182 (10.29.240.182): 56 data bytes
>> 64 bytes from 10.29.240.182: seq=0 ttl=63 time=0.6 ms
>> 64 bytes from 10.29.240.182: seq=1 ttl=63 time=0.6 ms
>>
>
> What is cs8900_irq_map set to with this patch or am I missing some thing?
>

Sorry my delay.

Please find definition below:

unsigned int cs8900_irq_map[] = { CS8900AIRQ, 0, 0, 0 };

/*! This is System IRQ used by CS8900A for interrupt generation taken
from platform.h */
#define CS8900AIRQ              EXPIO_INT_ENET_INT

#define EXPIO_INT_ENET_INT      (MXC_EXP_IO_BASE + 8)

> Regards,
> Sajith
>

Best Regards,

Alan
