From: Sampsa Riikonen <sampsa.riikonen@iki.fi>
Subject: the sis190 linux kernel module
Date: Thu, 10 Apr 2008 12:10:53 +0300
Message-ID: <1207818653.4973.37.camel@linux-q5nk.site>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:19562 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbYDJJK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 05:10:57 -0400
Received: by ug-out-1314.google.com with SMTP id z38so1235685ugc.16
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 02:10:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Francois,

>From the maintainers file I found out that you are the
developer of the sis190 network kernel module.

First of all, thank you very much for writing
this module.  I would like to report a problem
I encountered with it.

My network card is

SiS 191 Gigabit ethernet adapter (rev 02)

With the latest kernel (2.6.22.17-0.1-default),
and using OpenSuse 10.3 I get the following errors:

--------------------
linux-pmz9:/home/user # lspci -nn | grep net
00:04.0 Ethernet controller [Class 0200]: Silicon Integrated Systems
[SiS] 191 Gigabit Ethernet Adapter [1039:0191] (rev 02)

linux-pmz9:/home/user # lsmod | grep -i "sis"
sis190                 38788  0
mii                    22528  1 sis190
sata_sis               26756  4
pata_sis               33540  1 sata_sis
libata                164096  2 sata_sis,pata_sis

linux-pmz9:/home/user # dmesg | grep -i "00:04.0"
ACPI: PCI Interrupt 0000:00:04.0[A] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:04.0 to 64
0000:00:04.0: Read MAC address from APC.
0000:00:04.0: Can not find ISA bridge.
ACPI: PCI interrupt for device 0000:00:04.0 disabled
sis190: probe of 0000:00:04.0 failed with error -5
ACPI: PCI Interrupt 0000:00:04.0[A] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:04.0 to 64
0000:00:04.0: Read MAC address from APC.
0000:00:04.0: Can not find ISA bridge.
ACPI: PCI interrupt for device 0000:00:04.0 disabled
sis190: probe of 0000:00:04.0 failed with error -5
---------------

Is there a driver available for the sis191 card or
should the sis190 driver do the work?

Could this be a distribution specific problem?

Regards,

Sampsa Riikonen


