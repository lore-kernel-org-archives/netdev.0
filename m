From: Krzysztof Oledzki <olel@ans.pl>
Subject: BCM5721(tg3)&MSI
Date: Sun, 26 Jun 2005 01:24:14 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0506260116440.16847@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1833883756-1119741854=:16847"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1833883756-1119741854=:16847
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

Hello,

Which BCM chips support MSI? I have a mainbord with two BCM5721, it seems=
=20
both support MSI (Message Signalled Interrupts entry in Capabilities) but=
=20
with 2.6.12.1 tg3 driver does not enable it. Why?

04:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5721 Gigabit=
 Ethernet PCI Express (rev 11)
         Subsystem: Super Micro Computer Inc: Unknown device 02c6
         Flags: bus master, fast devsel, latency 0, IRQ 201
         Memory at d0100000 (64-bit, non-prefetchable) [size=3D64K]
         Capabilities: [48] Power Management version 2
         Capabilities: [50] Vital Product Data
         Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=3D0/=
3 Enable-
         Capabilities: [d0] #10 [0001]

05:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5721 Gigabit=
 Ethernet PCI Express (rev 11)
         Subsystem: Super Micro Computer Inc: Unknown device 02c6
         Flags: bus master, fast devsel, latency 0, IRQ 217
         Memory at d0200000 (64-bit, non-prefetchable) [size=3D64K]
         Capabilities: [48] Power Management version 2
         Capabilities: [50] Vital Product Data
         Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=3D0/=
3 Enable-
         Capabilities: [d0] #10 [0001]


# cat /proc/interrupts |grep eth
201:    1569474          0   IO-APIC-level  uhci_hcd:usb4, eth0
217:    1403373          0   IO-APIC-level  libata, uhci_hcd:usb3, eth1


eth0: Tigon3 [partno(BCM95721) rev 4101 PHY(5750)] (PCIX:100MHz:32-bit) 10/=
100/1000BaseT Ethernet 00:30:48:81:60:8e
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[1] TSOcap=
[1]
eth0: dma_rwctrl[76180000]
eth1: Tigon3 [partno(BCM95721) rev 4101 PHY(5750)] (PCIX:100MHz:32-bit) 10/=
100/1000BaseT Ethernet 00:30:48:81:60:8f
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[1] TSOcap=
[1]
eth1: dma_rwctrl[76180000]

# zgrep MSI /proc/config.gz
CONFIG_PCI_MSI=3Dy

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1833883756-1119741854=:16847--
