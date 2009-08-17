From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: TX on r8169 causes latency and messes up real-time apps, on some
	boards
Date: Mon, 17 Aug 2009 01:31:02 -0400
Message-ID: <cb0375e10908162231n26da814ep75d70d68409bb112@mail.gmail.com>
References: <cb0375e10908160339i4526b957nf73b0576f19da2bd@mail.gmail.com>
	 <20090817051926.GA10370@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f215.google.com ([209.85.220.215]:44472 "EHLO
	mail-fx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703AbZHQFbC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 01:31:02 -0400
Received: by fxm11 with SMTP id 11so2087505fxm.39
        for <netdev@vger.kernel.org>; Sun, 16 Aug 2009 22:31:02 -0700 (PDT)
In-Reply-To: <20090817051926.GA10370@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This might be a false alarm -- it's possible I'm just trying to exceed
available PCI bandwidth.  I'll email back if I find any more
convincing evidence it's a problem with r8169.

Thanks,
Andy

On Mon, Aug 17, 2009 at 1:19 AM, Francois Romieu<romieu@fr.zoreil.com> =
wrote:
> Andrew Lutomirski <luto@mit.edu> :
> [...]
>> @@ -125,6 +125,11 @@
>> =A0ACPI: No dock devices found.
>> =A0ACPI: PCI Root Bridge [PCI0] (0000:00)
>> =A0pci 0000:00:00.0: reg 10 32bit mmio: [0x48000000-0x49ffffff]
>> +pci 0000:00:02.7: reg 10 io port: [0x2200-0x22ff]
>> +pci 0000:00:02.7: reg 14 io port: [0x2300-0x237f]
>> +pci 0000:00:02.7: supports D1 D2
>> +pci 0000:00:02.7: PME# supported from D3hot D3cold
>> +pci 0000:00:02.7: PME# disabled
> [...]
>> @@ -157,34 +162,34 @@
>> =A0ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
>> =A0ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
>> =A0ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 *10 11 12 14 15)
>> -ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 10 *11 12 14 15)
>> -ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 10 11 12 14 15) *0, d=
isabled.
>> -ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 *10 11 12 14 15)
>> +ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 *10 11 12 14 15)
>> +ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 10 *11 12 14 15)
>> +ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 10 *11 12 14 15)
>
> There is some difference. Either the kernel, the board or the bios
> revision. I'd be surprized if the /proc/interrupts looked the same.
>
> --
> Ueimor
>
