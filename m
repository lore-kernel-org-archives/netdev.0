From: Andre Tomt <andre@tomt.net>
Subject: tg3 link state detection
Date: Tue, 21 Sep 2004 17:55:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41504EF0.4050208@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

With 2.6.8(.1)+the add_pin_to_irq fix we're seeing problem with link 
state detection using tg3 devices. The network in question has a severe 
case of cable monkeys, so the link is a bit jumpy.

 From time to time the tg3's do not detect that the link is up again, 
and thus has to be rebooted (ifdown/up has not been tested due to 
triggerhappy non-technical on-site monkeys.)

Is this a known problem?

> tg3.c:v3.8 (July 14, 2004)
> ACPI: PCI interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 185
> eth0: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet 00:0d:56:fe:4f:e7
> eth0: HostTXDS[1] RXcsums[1] LinkChgREG[1] MIirq[1] ASF[0] Split[0] WireSpeed[1] TSOcap[1]
> ACPI: PCI interrupt 0000:02:00.1[B] -> GSI 17 (level, low) -> IRQ 193
> eth1: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet 00:0d:56:fe:4f:e8
> eth1: HostTXDS[1] RXcsums[1] LinkChgREG[1] MIirq[1] ASF[0] Split[0] WireSpeed[1] TSOcap[1]
