From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: Support for Intel 82562V-2?
Date: Mon, 6 Aug 2007 10:54:56 -0700
Message-ID: <BD524EA7912ED5469DFD0BAEF6BC752F0256D088@orsmsx411.amr.corp.intel.com>
References: <20070806163819.GA18130@gateway.home>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Erik Mouw" <mouw@nl.linux.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11393 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753339AbXHFRzK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 13:55:10 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070806163819.GA18130@gateway.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While that is a "10/100 network connection", it is actually a GigE MAC
with a 10/100 PHY and will be supported by the e1000e driver that is
currently in the process of final cleanup before getting into the
upstream kernel.

If you must use it now, you can grab the latest out-of-tree version of
the e1000 driver from http://e1000.sf.net which has support for that
device.  There are no plans for adding support for this device to the
in-tree e1000 driver.

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Erik Mouw
Sent: Monday, August 06, 2007 9:38 AM
To: netdev@vger.kernel.org
Subject: Support for Intel 82562V-2?

Hi,

Just got a brand new Dell Vostro and it appears to have an unsupported
Intel network card:

00:19.0 Ethernet controller: Intel Corporation 82562V-2 10/100 Network
Connection (rev 02)
	Subsystem: Dell Unknown device 0238
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at fdfc0000 (32-bit, non-prefetchable)
[size=128K]
	Region 1: Memory at fdfff000 (32-bit, non-prefetchable)
[size=4K]
	Region 2: I/O ports at fe00 [size=32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+
Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [e0] Vendor Specific Information
00: 86 80 c0 10 07 00 10 00 02 00 00 02 00 00 00 00
10: 00 00 fc fd 00 f0 ff fd 01 fe 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 28 10 38 02
30: 00 00 00 00 c8 00 00 00 00 00 00 00 0a 01 00 00

The e100 driver doesn't recognise it and the "old" eepro100 also
doesn't. Would it be enought to add the PCI ID to one of these drivers
to get the card supported?


Erik

-- 
They're all fools. Don't worry. Darwin may be slow, but he'll
eventually get them. -- Matthew Lammers in alt.sysadmin.recovery
