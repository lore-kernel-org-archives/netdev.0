From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 2.6.16.13 e1000 reports incorrect PCI-X bus speed?
Date: Fri, 12 May 2006 14:41:01 -0700
Message-ID: <446500ED.6040002@hp.com>
References: <4464FB01.6070206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:43245 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S1750799AbWELVlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 May 2006 17:41:03 -0400
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4464FB01.6070206@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> I'm running a slightly modified 2.6.16.13 kernel on FC5-amd64.  The 
> motherboard
> is SuperMicro H8SSL dual-core AMD system.  According to super-micro web 
> site,
> the PCI-X slot is 133Mhz.  I'm using a 4-port pro/1000 NIC.
> 
> dmesg shows a listing of 120Mhz:

IIRC there is a bridge chip on those four-port cards.  Perhaps the 
"north" side of the bridge is at 133 MHz, but the south side (since it 
is more than one load) is only 120?

> Intel(R) PRO/1000 Network Driver - version 6.3.9-k4-NAPI
> Copyright (c) 1999-2005 Intel Corporation.
> GSI 18 sharing vector 0xB9 and IRQ 18
> ACPI: PCI Interrupt 0000:03:04.0[A] -> GSI 20 (level, low) -> IRQ 18
> e1000: 0000:03:04.0: e1000_probe: (PCI-X:120MHz:64-bit) 00:04:23:ad:41:bc
> e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
> GSI 19 sharing vector 0xC1 and IRQ 19
> ACPI: PCI Interrupt 0000:03:04.1[B] -> GSI 21 (level, low) -> IRQ 19
> e1000: 0000:03:04.1: e1000_probe: (PCI-X:120MHz:64-bit) 00:04:23:ad:41:bd
> e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
> GSI 20 sharing vector 0xC9 and IRQ 20
> ACPI: PCI Interrupt 0000:03:06.0[A] -> GSI 22 (level, low) -> IRQ 20
> e1000: 0000:03:06.0: e1000_probe: (PCI-X:120MHz:64-bit) 00:04:23:ad:41:be
> e1000: eth4: e1000_probe: Intel(R) PRO/1000 Network Connection
> GSI 21 sharing vector 0xD1 and IRQ 21
> ACPI: PCI Interrupt 0000:03:06.1[B] -> GSI 23 (level, low) -> IRQ 21
> e1000: 0000:03:06.1: e1000_probe: (PCI-X:120MHz:64-bit) 00:04:23:ad:41:bf
> e1000: eth5: e1000_probe: Intel(R) PRO/1000 Network Connection
> 
> ethtool -d eth3 shows 66Mhz:
> ....
> 0x00008: STATUS (Device status register) 0x00003B87
>       Duplex:                            full
>       Link up:                           link config
>       TBI mode:                          disabled
>       Link speed:                        1000Mb/s
>       Bus type:                          PCI-X
>       Bus speed:                         66MHz
>       Bus width:                         64-bit
> 
> Any idea why I see the slower bus speed reported?

That one though escapes me.

rick jones

> 
> More info available as needed.
> 
> Thanks,
> Ben
> 

