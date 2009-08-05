From: Pascal Terjan <pterjan@mandriva.com>
Subject: [PATCH] Add IDs for 3C905B-TX Fast Etherlink XL PCI
Date: Wed,  5 Aug 2009 16:11:39 +0200
Message-ID: <1249481499-9560-1-git-send-email-pterjan@mandriva.com>
Cc: netdev@vger.kernel.org, Pascal Terjan <pterjan@mandriva.com>
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.mandrax.org ([212.85.147.169]:46549 "EHLO n4.mandriva.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934290AbZHEOU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 10:20:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We found this old card which was not supported, and physically
looks similar to the other 3C905B we have (9055).

After adding the IDs it seems to work fine (MII report, dhcp, scp, ...)
---
 drivers/net/3c59x.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index c204168..4567588 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -235,6 +235,7 @@ enum vortex_chips {
 	CH_3C900B_FL,
 	CH_3C905_1,
 	CH_3C905_2,
+	CH_3C905B_TX,
 	CH_3C905B_1,
 
 	CH_3C905B_2,
@@ -307,6 +308,8 @@ static struct vortex_chip_info {
 	 PCI_USES_MASTER, IS_BOOMERANG|HAS_MII|EEPROM_RESET, 64, },
 	{"3c905 Boomerang 100baseT4",
 	 PCI_USES_MASTER, IS_BOOMERANG|HAS_MII|EEPROM_RESET, 64, },
+	{"3C905B-TX Fast Etherlink XL PCI",
+	 PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM|EXTRA_PREAMBLE, 128, },
 	{"3c905B Cyclone 100baseTx",
 	 PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM|EXTRA_PREAMBLE, 128, },
 
@@ -389,6 +392,7 @@ static struct pci_device_id vortex_pci_tbl[] = {
 	{ 0x10B7, 0x900A, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C900B_FL },
 	{ 0x10B7, 0x9050, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905_1 },
 	{ 0x10B7, 0x9051, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905_2 },
+	{ 0x10B7, 0x9054, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905B_TX },
 	{ 0x10B7, 0x9055, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905B_1 },
 
 	{ 0x10B7, 0x9058, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905B_2 },
-- 
1.6.4

