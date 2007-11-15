From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: tg3: strange errors and non-working-ness
Date: Thu, 15 Nov 2007 10:47:28 +0100
Message-ID: <20071115094728.GB2366@ff.dom.local>
References: <cccedfc60711131057y41630b99h44e1c611f3e92fda@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jon Nelson <jnelson@jamponi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:45987 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757287AbXKOJnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 04:43:21 -0500
Content-Disposition: inline
In-Reply-To: <cccedfc60711131057y41630b99h44e1c611f3e92fda@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13-11-2007 19:57, Jon Nelson wrote:
> I'm not sure if this is the right place,

Me too. Looks more like acpi or pci problem. Did you try to experiment
with something like: pci=noacpi or acpi=off boot parameters? Probably
some point to your .config and dmesg should be useful too, so taking
it to bugzilla and sending a number as a follow up to this thread
should be resonable.

Btw, I add main kernel to cc.

Regards,
Jarek P.


> but I've got a pair of GiG-E
> cards that do not work correctly. Everything appears to come up just
> fine, but sooner or later (typically fairly quickly) the cards weird
> out and never really come back.
> 
> The best info I've got is this:
> 
> Nov 10 22:21:19 frank kernel: tg3.c:v3.65 (August 07, 2006)
> Nov 10 22:21:19 frank kernel: ACPI: PCI Interrupt 0000:00:0b.0[A] ->
> Link [LNKB] -> GSI 3 (level, low) -> IRQ 3
> Nov 10 22:21:19 frank kernel: eth0: Tigon3 [partno(AC91002A1) rev 0105
> PHY(5701)] (PCI:33MHz:32-bit) 10/100/1000BaseT Ethernet
> 00:09:5b:09:b1:69
> Nov 10 22:21:19 frank kernel: eth0: RXcsums[1] LinkChgREG[0] MIirq[0]
> ASF[0] Split[0] WireSpeed[1] TSOcap[0]
> Nov 10 22:21:19 frank kernel: eth0: dma_rwctrl[76ff000f] dma_mask[64-bit]
> Nov 10 22:21:19 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> Nov 10 22:21:19 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> Nov 10 22:21:19 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> Nov 10 22:21:19 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> Nov 10 22:21:20 frank kernel: tg3: eth0: Link is up at 1000 Mbps, full duplex.
> Nov 10 22:21:20 frank kernel: tg3: eth0: Flow control is on for TX and
> on for RX.
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> Nov 10 22:21:20 frank kernel: ACPI: PCI interrupt for device
> 0000:00:0b.0 disabled
> Nov 10 22:21:20 frank kernel: PCI: Enabling device 0000:00:0b.0 (0100 -> 0102)
> Nov 10 22:21:20 frank kernel: ACPI: PCI Interrupt 0000:00:0b.0[A] ->
> Link [LNKB] -> GSI 3 (level, low) -> IRQ 3
> Nov 10 22:21:20 frank kernel: eth0: Tigon3 [partno(AC91002A1) rev 0105
> PHY(5701)] (PCI:33MHz:32-bit) 10/100/1000BaseT Ethernet
> 00:09:5b:09:b1:69
> Nov 10 22:21:20 frank kernel: eth0: RXcsums[1] LinkChgREG[0] MIirq[0]
> ASF[0] Split[0] WireSpeed[1] TSOcap[0]
> Nov 10 22:21:20 frank kernel: eth0: dma_rwctrl[76ff000f] dma_mask[64-bit]
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> Nov 10 22:21:20 frank kernel: tg3: eth0: Link is up at 1000 Mbps, full duplex.
> Nov 10 22:21:20 frank kernel: tg3: eth0: Flow control is on for TX and
> on for RX.
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> Nov 10 22:21:20 frank kernel: tg3: eth0: Link is up at 1000 Mbps, full duplex.
> Nov 10 22:21:20 frank kernel: tg3: eth0: Flow control is on for TX and
> on for RX.
> Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> Nov 10 22:41:48 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> Nov 10 22:41:48 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> Nov 10 22:41:48 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> Nov 10 22:41:48 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> Nov 10 22:41:48 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> Nov 10 22:41:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> Nov 10 22:41:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> Nov 10 22:41:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> Nov 10 22:41:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> Nov 10 22:43:02 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> Nov 10 22:45:52 frank kernel: NETDEV WATCHDOG: eth0: transmit timed out
> Nov 10 22:45:52 frank kernel: tg3: eth0: transmit timed out, resetting
> Nov 10 22:45:52 frank kernel: tg3: tg3_stop_block timed out, ofs=1400
> enable_bit=2
> Nov 10 22:45:52 frank kernel: tg3: tg3_stop_block timed out, ofs=c00
> enable_bit=2
> Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> Nov 10 22:45:52 frank kernel: tg3: eth0: Link is down.
> Nov 10 22:45:56 frank kernel: tg3: eth0: Link is up at 1000 Mbps, full duplex.
> Nov 10 22:45:56 frank kernel: tg3: eth0: Flow control is on for TX and
> on for RX.
> Nov 10 22:47:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> Nov 10 22:47:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> Nov 10 22:47:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> Nov 10 22:49:02 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> 
> Other gig-e cards work OK in this box.
> I have a *pair* of the TG3 boards and they both do the same thing.
> 
