From: dag@bakke.com
Subject: Troughput of dual 8139C/cardbus/bonding?
Date: Tue, 15 Jun 2004 07:35:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615073555.8005.h016.c000.wm@mail.bakke.com.criticalpath.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
Content-Disposition: inline
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.
(Jeff G., question for you further down.)

Would anyone on this list be so kind as to share with me their thoughts
on what troughput I should be able to obtain with two RTL8139C CardBus
cards in bonding mode, talking to an identical twin in the other end of
two crossed Ethernet cables?

The PCs I have are Toshiba laptops with a ToPIC95 PCItoCardBus bridge and
a 600MHz PIII. CardBus cards share the same interrupt. 

A single card gives me 95+ Mbps troughput (one or two-way udp traffic), 
two cards bonded offers at best 153 Mbps. (One way udp traffic)

It doesn't look like the bonding driver is the cuplprit here. Doing 
testing with separate networks on each pair of Ethernet links does not 
give better aggregate performance.

Furthermore, I find that the single-link performance occasionally drops
to 80 Mbps, or even 67 Mbps. And stays there.
The only way to get it back is by 'ifconfig down up' the interface.
Is this a bug, or some throttling mechanism in the kernel kicking in?
(Jeff....?)

I am currently running 2.6.7-rc2 and testing with iperf 1.7.0.
I'll happily provide more details to interested parties.


I'll use this setup to field-test a pair of devices with multiple
Ethernet ports in one end and a wireless (!) 155Mbps STM-1 interface in
the other end. 


Dag B
