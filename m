From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 06/10] vmxnet3: remove VMXNET3_MAX_DEVICES
Date: Tue, 15 Jan 2013 09:28:31 -0800
Message-ID: <1358270915-32758-7-git-send-email-stephen@networkplumber.org>
References: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:40879 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756859Ab3AORaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 12:30:14 -0500
Received: by mail-pb0-f41.google.com with SMTP id xa7so172138pbc.0
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 09:30:13 -0800 (PST)
In-Reply-To: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defined but never used.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index d862937..0e55153 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -45,7 +45,6 @@ MODULE_DEVICE_TABLE(pci, vmxnet3_pciid_table);
 
 static atomic_t devices_found;
 
-#define VMXNET3_MAX_DEVICES 10
 static int enable_mq = 1;
 static int irq_share_mode;
 
-- 
1.7.10.4
