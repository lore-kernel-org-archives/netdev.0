From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 01/02] r8169: add PCI ID for the 8168 in the Abit Fatal1ty
	F-190HD motherboard
Date: Tue, 6 Nov 2007 23:23:54 +0100
Message-ID: <20071106222354.GB22170@electric-eye.fr.zoreil.com>
References: <20071106222213.GA22170@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ciaran McCreesh <ciaran.mccreesh@blueyonder.co.uk>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58521 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754033AbXKFW3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 17:29:38 -0500
Content-Disposition: inline
In-Reply-To: <20071106222213.GA22170@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ciaran McCreesh <ciaran.mccreesh@blueyonder.co.uk>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b94fa7e..702334e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -171,6 +171,8 @@ static struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(0x16ec,			0x0116), 0, 0, RTL_CFG_0 },
 	{ PCI_VENDOR_ID_LINKSYS,		0x1032,
 		PCI_ANY_ID, 0x0024, 0, 0, RTL_CFG_0 },
+	{ 0x0001,				0x8168,
+		PCI_ANY_ID, 0x2410, 0, 0, RTL_CFG_2 },
 	{0,},
 };
 
-- 
1.5.3.3

