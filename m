From: Michael Leun <lkml20101129@newton.leun.net>
Subject: 2.6.35 -> 2.6.36 panic when vlan and promisc with tg3
Date: Mon, 29 Nov 2010 20:17:16 +0100
Message-ID: <20101129201716.1d0257c4@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

only kernel message I was able to capture on serial were:

UG: unable to handle kernel paging request at 01cc921c
IP: [<c034bfce>] vlan_hwaccel_do_receive+0x59/0xd0
*pdpt = 0000000036a2a001 *pde = 0000000000000000
Oops: 0002 [#1] SMP
last sysfs

Then machine dead.

In 2.6.35.x this did not happen (but vlans broken - cannot see vlan
tags with tcpdump),

To reproduce:

ip link set eth0 up
vconfig add eth0 2
ip link set eth0 promisc on

Machines with these ethernet cards I've seen to be affected:

Ethernet controller: Broadcom Corporation NetXtreme BCM5714 Gigabit
Ethernet (rev a3)

Ethernet controller: Broadcom Corporation NetXtreme BCM5752M Gigabit
Ethernet PCI Express (rev 02)

Machine with this card is NOT affected (no vlan hw accel?):

Ethernet controller: Broadcom Corporation NetLink BCM5906M Fast
Ethernet PCI Express (rev 02)


-- 
MfG,

Michael Leun
