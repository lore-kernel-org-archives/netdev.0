From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: Does Realtek RTL8110S and RTL8100C work ?
Date: Thu, 25 Mar 2010 21:02:56 +0100
Message-ID: <4BABC170.7080008@computer.org>
References: <hoab2m$kc0$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Markus Feldmann <feldmann_markus@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay008.isp.belgacom.be ([195.238.6.174]:36479 "EHLO
	mailrelay008.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754368Ab0CYUGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 16:06:15 -0400
In-Reply-To: <hoab2m$kc0$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Markus Feldmann wrote:
> i am thinking about buying a Mini-ITX Server with some Realtek Cips on
> the PCI Network Devices. These are
> Realtek RTL8110S
> Realtek RTL8100C
> 
> The Mini-ITX is a Jetway JNF92.
> Does anybody know whether they work good or should i keep the hands off
> these?

I've got a Jetway J7F4 which has two Realtek RTL8110S devices. They look like this:

# lshw
(...)
        *-network:0
             description: Ethernet interface
             product: RTL-8110SC/8169SC Gigabit Ethernet
             vendor: Realtek Semiconductor Co., Ltd.
             physical id: 9
             bus info: pci@0000:00:09.0
             logical name: eth0
             version: 10
             serial: 00:30:18:a4:e4:a4
             size: 1GB/s
             capacity: 1GB/s
             width: 32 bits
             clock: 66MHz
             capabilities: bus_master ethernet physical tp mii 10bt 10bt-fd 100bt 100bt-fd 1000bt 1000bt-fd autonegotiation
             configuration: autonegotiation=on broadcast=yes driver=r8169 driverversion=2.3LK-NAPI duplex=full ip=192.168.1.11 latency=64 link=yes maxlatency=64 mingnt=32 module=r8169 multicast=yes port=MII speed=1GB/s
        *-network:1
             description: Ethernet interface
             product: RTL-8110SC/8169SC Gigabit Ethernet
             vendor: Realtek Semiconductor Co., Ltd.
             physical id: b
             bus info: pci@0000:00:0b.0
             logical name: eth1
             version: 10
             serial: 00:30:18:a4:e4:a5
             size: 100MB/s
             capacity: 1GB/s
             width: 32 bits
             clock: 66MHz
             capabilities: bus_master ethernet physical tp mii 10bt 10bt-fd 100bt 100bt-fd 1000bt 1000bt-fd autonegotiation
             configuration: autonegotiation=on broadcast=yes driver=r8169 driverversion=2.3LK-NAPI duplex=full ip=10.20.0.3 latency=64 link=yes maxlatency=64 mingnt=32 module=r8169 multicast=yes port=MII speed=100MB/s
(...)

eth1 has auto-negotiated 100Mbit/s because it is hard-wired to a device which isn't gigabit-capable.

Cheers, Jan
