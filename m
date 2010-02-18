From: Joe Perches <joe@perches.com>
Subject: [PATCH] drivers/net/tehuti.c: Reapply use DEFINE_PCI_DEVICE_TABLE()
Date: Wed, 17 Feb 2010 18:08:55 -0800
Message-ID: <63f0493c99e6bc106b8e61f9a7471f3bb0edf7d5.1266458260.git.joe@perches.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1070 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755602Ab0BRCI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 21:08:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 865a21a5e3d1b384c559a44c898fcad93e187b82 overwrote
commit a3aa18842a5303fc28fcc4d57dbd16618bd830a0

Fix it.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tehuti.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index b295b92..2517cc0 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -66,7 +66,7 @@
 
 #include "tehuti.h"
 
-static struct pci_device_id __devinitdata bdx_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(bdx_pci_tbl) = {
 	{0x1FC9, 0x3009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x1FC9, 0x3010, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x1FC9, 0x3014, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-- 
1.7.0.14.g7e948

