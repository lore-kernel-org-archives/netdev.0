From: Pascal Terjan <pterjan@mandriva.com>
Subject: SiS 191 failure with MTU > 1496
Date: Fri, 29 May 2009 18:44:46 +0200
Message-ID: <1243615486.12871.44.camel@plop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ryu.zarb.org ([212.85.158.22]:36641 "EHLO ryu.zarb.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753853AbZE2Qyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2009 12:54:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On a laptop with such hardware, with default 1500 MTU I can't connect to
local machines, error bit LIMIT is set when receiving packets.

By decreasing the MTU to 1496 everything works fine.

Jun 28 20:03:13 localhost kernel: sis190 Gigabit Ethernet driver 1.2
loaded.
Jun 28 20:03:13 localhost kernel: sis190 0000:00:04.0: PCI INT A -> GSI
19 (level, low) -> IRQ 19
Jun 28 20:03:13 localhost kernel: 0000:00:04.0: Read MAC address from
EEPROM
Jun 28 20:03:13 localhost kernel: 0000:00:04.0: Error EEPROM read 0.
Jun 28 20:03:13 localhost kernel: 0000:00:04.0: Read MAC address from
APC.
Jun 28 20:03:13 localhost kernel: 0000:00:04.0: Realtek PHY RTL8201
transceiver at address 1.
Jun 28 20:03:13 localhost kernel: 0000:00:04.0: Using transceiver at
address 1 as default.
Jun 28 20:03:13 localhost kernel: 0000:00:04.0: SiS 191 PCI Gigabit
Ethernet adapter at f08c0c00 (IRQ: 19), 00:21:85:da:e1:51
Jun 28 20:03:13 localhost kernel: eth0: GMII mode.
Jun 28 20:03:13 localhost kernel: eth0: Enabling Auto-negotiation.

00:04.0 0200: 1039:0191 (rev 02)
	Subsystem: 1462:63f8
	Flags: bus master, medium devsel, latency 0, IRQ 19
	Memory at fddfcc00 (32-bit, non-prefetchable) [size=128]
	I/O ports at cc00 [size=128]
	Capabilities: [40] Power Management version 2
	Kernel driver in use: sis190
	Kernel modules: sis190

