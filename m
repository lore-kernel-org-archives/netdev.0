From: Vadim Dyadkin <dyadkin@lns.pnpi.spb.ru>
Subject: troubles with r8169
Date: Sun, 12 Aug 2007 22:37:11 +0400
Message-ID: <46BF5357.6080205@lns.pnpi.spb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dimail1.hmi.de ([134.30.95.50]:55300 "EHLO dimail1.hmi.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933600AbXHLSyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2007 14:54:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I need help from developers, may be, because I have some troubles with
r8169 card.
I use laptop ASUS a6tc. The network card in this laptop is r8169. Video
is GeForce Go 7300. When I load linux (I use linux almost always), the
network and video cards take the same IRQ every time.
************************
# cat /proc/interrupts
           CPU0       CPU1
  0:    3530622     177152    XT-PIC-XT        timer
  1:       1910          9   IO-APIC-edge      i8042
  8:          1          1   IO-APIC-edge      rtc
  9:      41627        115   IO-APIC-fasteoi   acpi
 12:        122         10   IO-APIC-edge      i8042
 14:         38         12   IO-APIC-edge      ide0
 15:      53721          8   IO-APIC-edge      ide1
 16:          0          0   IO-APIC-fasteoi   yenta
 17:      34909          1   IO-APIC-fasteoi   ohci_hcd:usb1
 18:         13          1   IO-APIC-fasteoi   ehci_hcd:usb2
 19:     332826          1   IO-APIC-fasteoi   nvidia, eth0
 20:          0          0   IO-APIC-fasteoi   sdhci:slot0
 21:      26981          1   IO-APIC-fasteoi   HDA Intel
NMI:          0          0
LOC:     177152    3530365
ERR:          1
MIS:          0
**************************
You can see, now it's 19, sometimes it's 17 or 21, but every time it is
the same.
Often, the computer hangs, only the reboot can help. In /var/log/messages:
************************
Jul 14 19:15:29 satah NETDEV WATCHDOG: eth0: transmit timed out
Jul 14 19:15:32 satah NVRM: Xid (0002:00): 16, Head 00000000 Count 00cfda2c
Jul 14 19:15:40 satah NVRM: Xid (0002:00): 16, Head 00000000 Count 00cfda2d
Jul 14 19:15:48 satah NVRM: Xid (0002:00): 16, Head 00000000 Count 00cfda2e
Jul 14 19:15:56 satah NVRM: Xid (0002:00): 16, Head 00000000 Count 00cfda2f
Jul 14 19:16:04 satah NVRM: Xid (0002:00): 16, Head 00000000 Count 00cfda30
Jul 14 19:16:12 satah NVRM: Xid (0002:00): 16, Head 00000000 Count 00cfda31
Jul 14 19:16:17 satah NETDEV WATCHDOG: eth0: transmit timed out
Jul 14 19:16:20 satah NVRM: Xid (0002:00): 16, Head 00000000 Count 00cfda32
Jul 14 19:16:35 satah NETDEV WATCHDOG: eth0: transmit timed out
Jul 14 19:16:53 satah NETDEV WATCHDOG: eth0: transmit timed out
****************************
There's no such problem in windows. Could you help me with it?

Thank you in advance,
Vadim

