From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: [PATCH] r8169: add new PCI ID
Date: Thu, 25 May 2006 10:24:46 +0900
Message-ID: <20060525102446.572bb5ca.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo30.po.2iij.net ([210.128.50.53]:17459 "EHLO mo30.po.2iij.net")
	by vger.kernel.org with ESMTP id S964810AbWEYBYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 21:24:54 -0400
To: romieu@fr.zoreil.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch add new PCI ID for r8169 driver.
RTL8110SBL has this PCI ID.

Please aply.

Yoichi

Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

diff -pruN -X tb0287/Documentation/dontdiff tb0287-orig/drivers/net/r8169.c tb0287/drivers/net/r8169.c
--- tb0287-orig/drivers/net/r8169.c	2006-05-25 10:09:43.981416000 +0900
+++ tb0287/drivers/net/r8169.c	2006-05-25 09:58:45.932290500 +0900
@@ -184,6 +184,7 @@ static const struct {
 
 static struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), },
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), },
 	{ PCI_DEVICE(0x16ec,			0x0116), },
 	{ PCI_VENDOR_ID_LINKSYS,		0x1032, PCI_ANY_ID, 0x0024, },


