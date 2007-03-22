From: linux@horizon.com
Subject: VIA Velocity VLAN vexation
Date: 22 Mar 2007 09:48:09 -0400
Message-ID: <20070322134809.4558.qmail@science.horizon.com>
Cc: linux@horizon.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:14333 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932437AbXCVNsK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 09:48:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have a machine (x86-32, 2.6.20.3) with two ethernet interfaces:
a 100M Tulip and a 1G VIA Velocity.  Both are connected to a common
VLAN-capable switch.  The eventually desired configuration is VLAN
support on the Gbit interface.

If I set the Tulip's switch port to tagged, and configure a VLAN on the
Tulip interface appropriately, packets flow as expected.

But if I try the same configuration on the Velocity interface, things
don't work.
I can see tagged ICMP pings go out, but no responses come back.
I can see ARP requests and responses on the target machine.
If I manually configure the ARP caches, I can see the pings and responses
on the target machine.
If I kludge the target's ARP cache to point back to the source's Tulip
interface, I can see the ping responses on the Tulip interface.

But I don't see the ping responses on the Velocity interface.

The vlan interface name and address is the same, so it can't be
firewall rules distinguishing.

I have tried various ping sizes from 0 to 1472.


Is this likely to be a problem with the via-velocity driver?
Is anyone working on it?  Or should I just get a different gigabit card?

Thanks for any advice!

00:09.0 Ethernet controller [0200]: VIA Technologies, Inc. VT6120/VT6121/VT6122 Gigabit Ethernet Adapter [1106:3119] (rev 11)
00:0d.0 PCI bridge [0604]: Digital Equipment Corporation DECchip 21152 [1011:0024] (rev 03)
02:04.0 Ethernet controller [0200]: Digital Equipment Corporation DECchip 21142/43 [1011:0019] (rev 41)
02:05.0 Ethernet controller [0200]: Digital Equipment Corporation DECchip 21142/43 [1011:0019] (rev 41)
02:06.0 Ethernet controller [0200]: Digital Equipment Corporation DECchip 21142/43 [1011:0019] (rev 41)
02:07.0 Ethernet controller [0200]: Digital Equipment Corporation DECchip 21142/43 [1011:0019] (rev 41)
