From: Simon Chen <simonchennj@gmail.com>
Subject: Re: under-performing bonded interfaces
Date: Wed, 16 Nov 2011 19:05:00 -0500
Message-ID: <CANj2EbfrtbysEbj+gMa+fOhWo0EWjBXVyGkw8WyiPAV9nPduuQ@mail.gmail.com>
References: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com>
	<4EC44ECB.4050201@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42615 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962Ab1KQAFB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 19:05:01 -0500
Received: by mail-fx0-f46.google.com with SMTP id n18so2232576fag.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 16:05:00 -0800 (PST)
In-Reply-To: <4EC44ECB.4050201@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If used independently, I can get around 9.8Gbps.

Here is from dmesg:
[   11.386736] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
version 3.2.9-k2
[   11.386738] ixgbe: Copyright (c) 1999-2010 Intel Corporation.
[   11.386778] ixgbe 0000:03:00.0: PCI INT A -> GSI 24 (level, low) -> =
IRQ 24
[   11.386788] ixgbe 0000:03:00.0: setting latency timer to 64
[   11.572715] ixgbe 0000:03:00.0: irq 75 for MSI/MSI-X
[   11.572720] ixgbe 0000:03:00.0: irq 76 for MSI/MSI-X
[   11.572728] ixgbe 0000:03:00.0: irq 77 for MSI/MSI-X
[   11.572733] ixgbe 0000:03:00.0: irq 78 for MSI/MSI-X
[   11.572737] ixgbe 0000:03:00.0: irq 79 for MSI/MSI-X
[   11.572741] ixgbe 0000:03:00.0: irq 80 for MSI/MSI-X
[   11.572745] ixgbe 0000:03:00.0: irq 81 for MSI/MSI-X
[   11.572750] ixgbe 0000:03:00.0: irq 82 for MSI/MSI-X
[   11.572755] ixgbe 0000:03:00.0: irq 83 for MSI/MSI-X
[   11.572759] ixgbe 0000:03:00.0: irq 84 for MSI/MSI-X
[   11.572766] ixgbe 0000:03:00.0: irq 85 for MSI/MSI-X
[   11.572770] ixgbe 0000:03:00.0: irq 86 for MSI/MSI-X
[   11.572775] ixgbe 0000:03:00.0: irq 87 for MSI/MSI-X
[   11.572779] ixgbe 0000:03:00.0: irq 88 for MSI/MSI-X
[   11.572783] ixgbe 0000:03:00.0: irq 89 for MSI/MSI-X
[   11.572787] ixgbe 0000:03:00.0: irq 90 for MSI/MSI-X
[   11.572791] ixgbe 0000:03:00.0: irq 91 for MSI/MSI-X
[   11.572795] ixgbe 0000:03:00.0: irq 92 for MSI/MSI-X
[   11.572799] ixgbe 0000:03:00.0: irq 93 for MSI/MSI-X
[   11.572803] ixgbe 0000:03:00.0: irq 94 for MSI/MSI-X
[   11.572807] ixgbe 0000:03:00.0: irq 95 for MSI/MSI-X
[   11.572812] ixgbe 0000:03:00.0: irq 96 for MSI/MSI-X
[   11.572816] ixgbe 0000:03:00.0: irq 97 for MSI/MSI-X
[   11.572820] ixgbe 0000:03:00.0: irq 98 for MSI/MSI-X
[   11.572825] ixgbe 0000:03:00.0: irq 99 for MSI/MSI-X
[   11.572857] ixgbe 0000:03:00.0: Multiqueue Enabled: Rx Queue count
=3D 24, Tx Queue count =3D 24
[   11.572861] ixgbe 0000:03:00.0: (PCI Express:5.0Gb/s:Width x4)
e8:9a:8f:23:42:1a
[   11.572943] ixgbe 0000:03:00.0: MAC: 2, PHY: 8, SFP+: 3, PBA No: FFF=
=46FF-0FF
[   11.572944] ixgbe 0000:03:00.0: PCI-Express bandwidth available for
this card is not sufficient for optimal performance.
[   11.572946] ixgbe 0000:03:00.0: For optimal performance a x8
PCI-Express slot is required.
[   11.573815] ixgbe 0000:03:00.0: Intel(R) 10 Gigabit Network Connecti=
on
[   11.573833] ixgbe 0000:03:00.1: PCI INT B -> GSI 34 (level, low) -> =
IRQ 34
[   11.573839] ixgbe 0000:03:00.1: setting latency timer to 64
[   11.743748] ixgbe 0000:03:00.1: irq 100 for MSI/MSI-X
[   11.743753] ixgbe 0000:03:00.1: irq 101 for MSI/MSI-X
[   11.743758] ixgbe 0000:03:00.1: irq 102 for MSI/MSI-X
[   11.743762] ixgbe 0000:03:00.1: irq 103 for MSI/MSI-X
[   11.743769] ixgbe 0000:03:00.1: irq 104 for MSI/MSI-X
[   11.743773] ixgbe 0000:03:00.1: irq 105 for MSI/MSI-X
[   11.743777] ixgbe 0000:03:00.1: irq 106 for MSI/MSI-X
[   11.743781] ixgbe 0000:03:00.1: irq 107 for MSI/MSI-X
[   11.743785] ixgbe 0000:03:00.1: irq 108 for MSI/MSI-X
[   11.743789] ixgbe 0000:03:00.1: irq 109 for MSI/MSI-X
[   11.743793] ixgbe 0000:03:00.1: irq 110 for MSI/MSI-X
[   11.743796] ixgbe 0000:03:00.1: irq 111 for MSI/MSI-X
[   11.743800] ixgbe 0000:03:00.1: irq 112 for MSI/MSI-X
[   11.743804] ixgbe 0000:03:00.1: irq 113 for MSI/MSI-X
[   11.743808] ixgbe 0000:03:00.1: irq 114 for MSI/MSI-X
[   11.743815] ixgbe 0000:03:00.1: irq 115 for MSI/MSI-X
[   11.743819] ixgbe 0000:03:00.1: irq 116 for MSI/MSI-X
[   11.743823] ixgbe 0000:03:00.1: irq 117 for MSI/MSI-X
[   11.743827] ixgbe 0000:03:00.1: irq 118 for MSI/MSI-X
[   11.743831] ixgbe 0000:03:00.1: irq 119 for MSI/MSI-X
[   11.743835] ixgbe 0000:03:00.1: irq 120 for MSI/MSI-X
[   11.743839] ixgbe 0000:03:00.1: irq 121 for MSI/MSI-X
[   11.743843] ixgbe 0000:03:00.1: irq 122 for MSI/MSI-X
[   11.743847] ixgbe 0000:03:00.1: irq 123 for MSI/MSI-X
[   11.743851] ixgbe 0000:03:00.1: irq 124 for MSI/MSI-X
[   11.743882] ixgbe 0000:03:00.1: Multiqueue Enabled: Rx Queue count
=3D 24, Tx Queue count =3D 24
[   11.743886] ixgbe 0000:03:00.1: (PCI Express:5.0Gb/s:Width x4)
e8:9a:8f:23:42:1b

I have a 24 cores (just showing the last one).

processor       : 23
vendor_id       : GenuineIntel
cpu family      : 6
model           : 44
model name      : Intel(R) Xeon(R) CPU           X5650  @ 2.67GHz
stepping        : 2
cpu MHz         : 2668.000
cache size      : 12288 KB
physical id     : 1
siblings        : 12
core id         : 10
cpu cores       : 6
apicid          : 53
initial apicid  : 53
fpu             : yes
fpu_exception   : yes
cpuid level     : 11
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts
rep_good nopl xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64
monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2
popcnt aes lahf_lm ida arat epb dts tpr_shadow vnmi flexpriority ept
vpid
bogomips        : 5333.52
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management:

thanks!
-Simon

On Wed, Nov 16, 2011 at 7:01 PM, Ben Greear <greearb@candelatech.com> w=
rote:
> On 11/16/2011 03:44 PM, Simon Chen wrote:
>>
>> Hello,
>>
>> I am bonding two 10G interfaces (ixgbe driver) under Debian 6.0.2. T=
he
>> bonded interface for some reason can only achieve 12Gbps aggregated
>> throughput. If a single NIC is used, I can get close to 10Gbps.
>>
>> I've tried different bonding modes (balance-xor, 802.3ad, balance-al=
b,
>> balance-tlb), and different xmit hashing policy (layer2, layer2+3,
>> layer3+4). I've increased all types of kernel parameters for TCP. MT=
U
>> on the physical and bonded interface is set to 8000 and 9000. The MT=
U
>> on the switch is 9200+.
>>
>> Instead of nperf (a single server), I also tried my own TCP sender a=
nd
>> receivers.
>>
>> All those done, still only 12Gbps... How can I really achieve close =
to
>> 20Gbps?
>>
>> (I also tried cutting loose the switch in between, and also getting
>> 12G, so not an issue with the switch.)
>
> How much can you get if you run each of the NIC ports independently
> w/out bonding? =A0Plz send the 'dmesg' messages about ixgbe (ie, how
> many lanes, how many GT/s). =A0What is your processor?
>
> Thanks,
> Ben
>
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc =A0http://www.candelatech.com
>
>
