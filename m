From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: sky2 hang.
Date: Tue, 31 Oct 2006 09:11:44 +0300
Message-ID: <20061031061144.GA1562@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47047 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1161573AbWJaGLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 01:11:42 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sky2 from debian etch kernel (2.6.17-2) has stopped today after quite
big amount of traffic transferred (30MB/sec for about 3-4 hours).
rmmod/insmod does not help, reboot required.

Here is dmesg output:

Oct 31 06:40:07 kano kernel: NETDEV WATCHDOG: eth0: transmit timed out
Oct 31 06:40:07 kano kernel: sky2 eth0: tx timeout
Oct 31 06:40:07 kano kernel: sky2 eth0: transmit ring 198 .. 175 report=221 done=221
Oct 31 06:40:07 kano kernel: sky2 status report lost?
Oct 31 06:40:42 kano kernel: NETDEV WATCHDOG: eth0: transmit timed out
Oct 31 06:40:42 kano kernel: sky2 eth0: tx timeout
Oct 31 06:40:42 kano kernel: sky2 eth0: transmit ring 221 .. 198 report=221 done=221
Oct 31 06:40:42 kano kernel: sky2 hardware hung? flushing
Oct 31 06:54:07 kano kernel: NETDEV WATCHDOG: eth0: transmit timed out
Oct 31 06:54:07 kano kernel: sky2 eth0: tx timeout
Oct 31 06:54:07 kano kernel: sky2 eth0: transmit ring 198 .. 175 report=221 done=221
Oct 31 06:54:07 kano kernel: sky2 status report lost?
Oct 31 06:54:42 kano kernel: NETDEV WATCHDOG: eth0: transmit timed out
Oct 31 06:54:42 kano kernel: sky2 eth0: tx timeout
Oct 31 06:54:42 kano kernel: sky2 eth0: transmit ring 221 .. 198 report=221 done=221
Oct 31 06:54:42 kano kernel: sky2 hardware hung? flushing

And here is rmmod/insmod dmesg:

Oct 31 08:58:19 kano kernel: sky2 eth0: disabling interface
Oct 31 08:59:00 kano kernel: ACPI: PCI interrupt for device 0000:05:00.0 disabled
Oct 31 08:59:21 kano kernel: ACPI: PCI Interrupt 0000:05:00.0[A] -> Link [LNKD] -> GSI 18 (level, low) -> IRQ 98
Oct 31 08:59:21 kano kernel: PCI: Setting latency timer of device 0000:05:00.0 to 64
Oct 31 08:59:21 kano kernel: sky2 v1.6.1 addr 0xfbefc000 irq 98 Yukon-EC (0xb6) rev 2
Oct 31 08:59:21 kano kernel: sky2 eth0: addr 00:17:31:9a:e5:be
Oct 31 08:59:21 kano kernel: sky2 eth0: enabling interface
Oct 31 08:59:21 kano kernel: ADDRCONF(NETDEV_UP): eth0: link is not ready
Oct 31 08:59:23 kano kernel: sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control both
Oct 31 08:59:23 kano kernel: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

-- 
	Evgeniy Polyakov
