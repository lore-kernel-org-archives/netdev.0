From: Wojtek Sawasciuk <voyo@no-ip.pl>
Subject: not supported broadcom (?) NIC revision
Date: Fri, 16 Oct 2009 15:03:43 +0200
Message-ID: <4AD86F2F.90809@no-ip.pl>
Reply-To: Wojtek Sawasciuk <voyo@no-ip.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, davem@davemloft.net, jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from indra.unima2000.com.pl ([83.238.137.40]:41714 "EHLO
	indra.unima2000.com.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932339AbZJPNh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 09:37:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'v got server with built-in 9 NIC ports. Two ports are not recognized 
by any driver, I suppose it *should* be by tg3 or bnx2
Below is lspci info, not supported NIC are in slots 00:10.0 and 00:10.2
strange thing is that this vendor is described as Serverworks, but lspci 
says its Broadcom.

# grep 1166 include/linux/pci_ids.h
#define PCI_VENDOR_ID_SERVERWORKS         0x1166

Can someone help here ?


# lspci
00:00.0 Host bridge: Broadcom GCNB-LE Host Bridge (rev 32)
00:00.1 Host bridge: Broadcom GCNB-LE Host Bridge
00:02.0 Ethernet controller: Intel Corporation 82541GI Gigabit Ethernet 
Controller (rev 05)
00:0f.0 ISA bridge: Broadcom CSB5 South Bridge (rev 93)
00:0f.1 IDE interface: Broadcom CSB5 IDE Controller (rev 93)
00:0f.2 USB Controller: Broadcom OSB4/CSB5 OHCI USB Controller (rev 05)
00:0f.3 Host bridge: Broadcom CSB5 LPC bridge

00:10.0 Host bridge: Broadcom CIOB-E I/O Bridge with Gigabit Ethernet 
(rev 12)
00:10.2 Host bridge: Broadcom CIOB-E I/O Bridge with Gigabit Ethernet 
(rev 12)

02:02.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet 
Controller (rev 03)
02:02.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet 
Controller (rev 03)
02:04.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet 
Controller (rev 03)
02:04.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet 
Controller (rev 03)
03:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5704 
Gigabit Ethernet (rev 02)
03:00.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5704 
Gigabit Ethernet (rev 02)


00:10.0 0600: 1166:0110 (rev 12)
        Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort+ >SERR- <PERR-
        Capabilities: [60] PCI-X non-bridge device
                Command: DPERE- ERO- RBC=512 OST=8
                Status: Dev=00:00.0 64bit+ 133MHz+ SCD- USC- DC=bridge 
DMMRBC=512 DMOST=8 DMCRS=8 RSCEM- 266MHz- 533MHz-

00:10.2 0600: 1166:0110 (rev 12)
        Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort+ >SERR- <PERR-
        Capabilities: [60] PCI-X non-bridge device
                Command: DPERE- ERO- RBC=512 OST=8
                Status: Dev=00:00.0 64bit+ 133MHz+ SCD- USC- DC=bridge 
DMMRBC=512 DMOST=8 DMCRS=8 RSCEM- 266MHz- 533MHz-





