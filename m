From: fangxiaozhi 00110321 <huananhu@huawei.com>
Subject: [PATCH 1/5]net: PPP buffer too small for higher speed connections
Date: Tue, 17 Nov 2009 19:59:05 +0800
Message-ID: <fb8cc3511cffa.1cffafb8cc351@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	william.allen.simpson@gmail.com, jarkao2@gmail.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755989AbZKQL7D@vger.kernel.org>
Content-language: zh-CN
Content-disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: fangxiaozhi <huananhu@huawei.com>
1. This patch is based on the kernel of 2.6.32-rc7 
2. In this patch, we enlarge the out buffer size to optimize the upload speed for the ppp connection. Then it can support the upload of HSUPA data cards.
Signed-off-by: fangxiaozhi <huananhu@huawei.com>
-----------------------------------------------------------------------------------------
--- a/drivers/net/ppp_async.c	2009-10-12 05:43:56.000000000 +0800
+++ b/drivers/net/ppp_async.c	2009-10-15 16:29:56.000000000 +0800
@@ -36,7 +36,7 @@
 
 #define PPP_VERSION	"2.4.2"
 
-#define OBUFSIZE	256
+#define OBUFSIZE	4096
 
 /* Structure for storing local state. */
 struct asyncppp {


******************************************************************************************
 This email and its attachments contain confidential information from HUAWEI, which is intended only for the person or entity whose address is listed above. Any use of the information contained here in any way (including, but not limited to, total or partial disclosure, reproduction, or dissemination) by persons other than the intended recipient(s) is prohibited. If you receive this email in error, please notify the sender by phone or email
 immediately and delete it!
 *****************************************************************************************
