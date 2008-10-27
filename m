From: =?UTF-8?Q?Bart=C5=82omiej_Zimo=C5=84?= <uzi18@o2.pl>
Subject: =?UTF-8?Q?forcedeth_and_communication_problem_(MAC=3F)?=
Date: Mon, 27 Oct 2008 09:42:46 +0100
Message-ID: <792db4ad.644ed1a.49057f06.55d6f@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tur.go2.pl ([193.17.41.50]:58520 "EHLO tur.go2.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314AbYJ0IoY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 04:44:24 -0400
Received: from rekin23.go2.pl (rekin23.go2.pl [193.17.41.16])
	by tur.go2.pl (o2.pl Mailer 2.0.1) with ESMTP id 8B7F1231F4B
	for <netdev@vger.kernel.org>; Mon, 27 Oct 2008 09:44:22 +0100 (CET)
Received: from rekin23.go2.pl (rekin23 [127.0.0.1])
	by rekin23.go2.pl (Postfix) with ESMTP id 61F2D128804
	for <netdev@vger.kernel.org>; Mon, 27 Oct 2008 09:42:50 +0100 (CET)
Received: from o2.pl (unknown [10.0.0.38])
	by rekin23.go2.pl (Postfix) with SMTP
	for <netdev@vger.kernel.org>; Mon, 27 Oct 2008 09:42:47 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've just subscribed on this list, so Hi ALL! 

I haven't jet fill bug but have some problems wtith forcedeth
Looks like bug with suspend but after restart i can't use eth0.

I have 2nd motherboard with this issue.
Thirst was with nforce 560 (here sims not buitin card?) 
now with nforce 570 (builtin with PHY onboard) .
Both are different (MSI/ASROCK)

Usualy after computer restart i have no connection.
reproducable: linux -> linux, linux -> windows, windows -> linux

My Solution: Power off power supply until discharge +5FSB

The question is - what to check to have more information for You?
Where could be problem? 
Could it be connected with reverse stored mac ?

Thank You for help.

$ lspci
00:00.0 RAM memory: nVidia Corporation MCP55 Memory Controller (rev a2)
00:01.0 ISA bridge: nVidia Corporation MCP55 LPC Bridge (rev a3)
00:01.1 SMBus: nVidia Corporation MCP55 SMBus (rev a3)
00:02.0 USB Controller: nVidia Corporation MCP55 USB Controller (rev a1)
00:02.1 USB Controller: nVidia Corporation MCP55 USB Controller (rev a2)
00:04.0 IDE interface: nVidia Corporation MCP55 IDE (rev a1)
00:05.0 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a3)
00:05.1 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a3)
00:05.2 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a3)
00:06.0 PCI bridge: nVidia Corporation MCP55 PCI bridge (rev a2)
00:06.1 Audio device: nVidia Corporation MCP55 High Definition Audio (rev a2)
00:08.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a3)
00:0a.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a3)
00:0b.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a3)
00:0c.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a3)
00:0d.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a3)
00:0e.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a3)
00:0f.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a3)
00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration
00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
01:06.0 Network controller: Techsan Electronics Co Ltd B2C2 FlexCopII DVB chip / Technisat SkyStar2 DVB card (rev 02)
01:07.0 Multimedia controller: Philips Semiconductors SAA7134/SAA7135HL Video Broadcast Decoder (rev 01)
01:08.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139/8139C/8139C+ (rev 10)
08:00.0 VGA compatible controller: ATI Technologies Inc Device 9442
08:00.1 Audio device: ATI Technologies Inc Device aa30


