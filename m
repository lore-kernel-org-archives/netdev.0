From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: E1000 (PCI-E) doesn't work on nforce430, MSI issue.
Date: Tue, 12 Feb 2008 22:25:53 +0100
Message-ID: <m37ih9ooim.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:40162 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752790AbYBLVZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 16:25:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Is it a known problem?
Linux 2.6.24.2, ASUS M2NPV-MX mobo, nforce 430 based, two PCI-E x1
E1000 cards, 32-bit kernel, default e1000 driver (PCI IDs disabled in
e1000e).

Don't work by default. "pci=nomsi" fixes the problem.

82572EI Gigabit Ethernet Controller (Copper) (rev 06)
Subsystem: PRO/1000 PT Desktop Adapter

(8086:10b9 subsystem 8086:1083)

grep eth0 /proc/interrupts 
 20:       1945          1   IO-APIC-fasteoi   eth0

(without "pci=nomsi":
221:          0          0   PCI-MSI-edge      eth0)

other devices of possible interest:
00:00.0 RAM memory: nVidia Corporation C51 Host Bridge (rev a2)
00:00.1 RAM memory: nVidia Corporation C51 Memory Controller 0 (rev a2)
00:00.2 RAM memory: nVidia Corporation C51 Memory Controller 1 (rev a2)
00:00.3 RAM memory: nVidia Corporation C51 Memory Controller 5 (rev a2)
00:00.4 RAM memory: nVidia Corporation C51 Memory Controller 4 (rev a2)
00:00.5 RAM memory: nVidia Corporation C51 Host Bridge (rev a2)
00:00.6 RAM memory: nVidia Corporation C51 Memory Controller 3 (rev a2)
00:00.7 RAM memory: nVidia Corporation C51 Memory Controller 2 (rev a2)
00:03.0 PCI bridge: nVidia Corporation C51 PCI Express Bridge (rev a1)
00:04.0 PCI bridge: nVidia Corporation C51 PCI Express Bridge (rev a1)
00:09.0 RAM memory: nVidia Corporation MCP51 Host Bridge (rev a2)
00:0a.0 ISA bridge: nVidia Corporation MCP51 LPC Bridge (rev a3)
00:0a.1 SMBus: nVidia Corporation MCP51 SMBus (rev a3)
00:0a.2 RAM memory: nVidia Corporation MCP51 Memory Controller 0 (rev a3)
00:10.0 PCI bridge: nVidia Corporation MCP51 PCI Bridge (rev a2)

Additional details on request.
-- 
Krzysztof Halasa
