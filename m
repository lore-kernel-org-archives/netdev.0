From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 5/6] qlcnic: fix bios version check
Date: Mon,  8 Mar 2010 02:14:49 -0800
Message-ID: <1268043290-19929-6-git-send-email-amit.salecha@qlogic.com>
References: <1268043290-19929-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:54267 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753424Ab0CHKOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 05:14:53 -0500
In-Reply-To: <1268043290-19929-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bios sub version from unified fw image is calculated incorrect.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_init.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 21a6e9f..7c34e4e 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -847,7 +847,7 @@ qlcnic_get_bios_version(struct qlcnic_adapter *adapter)
 	bios_ver = cpu_to_le32(*((u32 *) (&fw->data[prd_off])
 				+ QLCNIC_UNI_BIOS_VERSION_OFF));
 
-	return (bios_ver << 24) + ((bios_ver >> 8) & 0xff00) + (bios_ver >> 24);
+	return (bios_ver << 16) + ((bios_ver >> 8) & 0xff00) + (bios_ver >> 24);
 }
 
 int
-- 
1.6.0.2

