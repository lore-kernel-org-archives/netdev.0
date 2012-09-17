From: "James R. Hay" <jrhay@haya.qc.ca>
Subject: D-Link DGE-530T and r8169.c
Date: Mon, 17 Sep 2012 11:51:08 -0400 (EDT)
Message-ID: <alpine.LNX.2.00.1209171139540.11109@hay.haya.qc.ca>
Reply-To: "James R. Hay" <jrhay@haya.qc.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: romieu@fr.zorrell.com, nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.hay-net.net ([205.236.99.37]:47314 "EHLO
	mail4.hay-net.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932211Ab2IQQBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 12:01:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Good morning,

It appears that D-Link has changed the ID of the DGE-530T NIC from 
1186:4300: to 1186:4302: which means the RTL8169 driver in the linux 
kernel does not recognize newer DGE-530T cards.

At link 199 of r8169.c is the following:

 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },

While I changed the 0x4300 to 0x4302 and recompiled the kernel to get the 
driver to recognize the card I believe that the appropriate fix would be 
to add the following line immediately after:

 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4302), 0, 0, RTL_CFG_0 },

Since I only have the one machine here on which to test this driver I am 
hoping that any further testing needed can be done by someone so that this 
can make its way inte the kernel source code.

Jim.

James R. Hay				jrhay@HayA.QC.CA
Hay-Net Networks			http://www.hay-net.net
P.O. Box 46051
Pointe Claire, QC
H9R 5R4
