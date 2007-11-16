From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9391] New: Netgear GA320T(tg3) strange errors
 and non-workingness
Date: Thu, 15 Nov 2007 18:18:09 -0800
Message-ID: <20071115181809.592a110c.akpm@linux-foundation.org>
References: <bug-9391-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50602 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756657AbXKPCSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 21:18:40 -0500
In-Reply-To: <bug-9391-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Nov 2007 18:04:19 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9391
> 
>            Summary: Netgear GA320T(tg3) strange errors and non-workingness
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.22.12 (openSUSE 10.3)
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: jnelson-kernel-bugzilla@jamponi.net
> 
> 
> Most recent kernel where this bug did not occur: 2.4.something
> 
> Distribution: openSUSE 10.3
> 
> Hardware Environment: Athlon XP 2200+
> Software Environment: 2.6.22.12
> Problem Description: this bug is being created from a mailing list discussion.
> 
> I've got a pair of GiG-E
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
> 
