From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make s2io.c:init_tti() static
Date: Wed, 30 Jan 2008 22:02:39 +0200
Message-ID: <20080130200239.GX29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Surjit Reang <surjit.reang@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	santosh.rastapur@neterion.com, sivakumar.subrama
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:51755 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758711AbYA3UCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:02:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the needlessly global init_tti() static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
1e8c2b07be955b181814e4c24366517a66557908 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 5fab7d7..bc94e84 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -1088,7 +1088,7 @@ static int s2io_print_pci_mode(struct s2io_nic *nic)
  *  '-1' on failure
  */
 
-int init_tti(struct s2io_nic *nic, int link)
+static int init_tti(struct s2io_nic *nic, int link)
 {
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	register u64 val64 = 0;

