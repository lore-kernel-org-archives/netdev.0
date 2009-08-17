From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: TX on r8169 causes latency and messes up real-time apps, on
	some boards
Date: Mon, 17 Aug 2009 07:19:26 +0200
Message-ID: <20090817051926.GA10370@electric-eye.fr.zoreil.com>
References: <cb0375e10908160339i4526b957nf73b0576f19da2bd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew Lutomirski <luto@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39805 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751238AbZHQFPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 01:15:15 -0400
Content-Disposition: inline
In-Reply-To: <cb0375e10908160339i4526b957nf73b0576f19da2bd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lutomirski <luto@mit.edu> :
[...]
> @@ -125,6 +125,11 @@
>  ACPI: No dock devices found.
>  ACPI: PCI Root Bridge [PCI0] (0000:00)
>  pci 0000:00:00.0: reg 10 32bit mmio: [0x48000000-0x49ffffff]
> +pci 0000:00:02.7: reg 10 io port: [0x2200-0x22ff]
> +pci 0000:00:02.7: reg 14 io port: [0x2300-0x237f]
> +pci 0000:00:02.7: supports D1 D2
> +pci 0000:00:02.7: PME# supported from D3hot D3cold
> +pci 0000:00:02.7: PME# disabled
[...]
> @@ -157,34 +162,34 @@
>  ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
>  ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
>  ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 *10 11 12 14 15)
> -ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 10 *11 12 14 15)
> -ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 10 11 12 14 15) *0, disabled.
> -ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 *10 11 12 14 15)
> +ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 *10 11 12 14 15)
> +ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 10 *11 12 14 15)
> +ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 10 *11 12 14 15)

There is some difference. Either the kernel, the board or the bios
revision. I'd be surprized if the /proc/interrupts looked the same.

-- 
Ueimor
