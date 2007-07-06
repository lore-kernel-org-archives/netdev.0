From: Ben Greear <greearb@candelatech.com>
Subject: Does the Netxen driver work?
Date: Fri, 06 Jul 2007 12:05:49 -0700
Message-ID: <468E928D.20606@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:56260 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762165AbXGFTFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 15:05:50 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id l66J5nZN022685
	for <netdev@vger.kernel.org>; Fri, 6 Jul 2007 12:05:49 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

I just got some Netxen 10Gbe CX4 adapters and put them into freshly
updated Fedora 7 64-bit systems.  So far, I am not having much luck.

Kernel is:  Official F7  2.6.21-1.3228.fc7

NIC:
01:00.0 Ethernet controller: NetXen Incorporated NXB-10GCX4 10 Gigabit Ethernet PCIe Adapter with CX4 copper interface (rev 25)

The motherboard chipset is Intel based (I can provide more info is someone
cares..but I first wanted to make sure there are no well-known issues.)

Interesting boot messages:

Jul  5 16:15:17 a440-dc kernel: ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 16 (level, low) -> IRQ 16
Jul  5 16:15:17 a440-dc kernel: netxen-nic: unable to allocate MSI interrupt error
Jul  5 16:15:17 a440-dc kernel: netxen-nic: XGbE board initialized

Is that MSI error fatal?

The two NICs are connected by a CX4 cable, and from dmesg output, it appears
they have negotiated link properly.

However, I see tx counters incrementing on both sides, but no rx counters.

I will try the latest 22-pre kernel in the meantime, but if anyone has
any experience getting these NICs to work, I'm interested to know about it.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

