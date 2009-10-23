From: fangxiaozhi 00110321 <huananhu@huawei.com>
Subject: [PATCH 23/10] Optimize the upload speed for PPP connection.
Date: Fri, 23 Oct 2009 17:47:46 +0800
Message-ID: <f98f8abb3f92.3f92f98f8abb@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: kernel@vger.kernel.org, zihan@huawei.com, greg@kroah.com,
	haegar@sdinet.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:41222 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbZJWJs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 05:48:59 -0400
Content-language: zh-CN
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fangxiaozhi <huananhu@huawei.com>
1. This patch is based on the kernel of 2.6.32-rc4 
2. In this patch, we enlarge the out buffer size to optimize the upload speed for the ppp connection. Then it can support the upload of HSUPA data cards.
Signed-off-by: fangxiaozhi <huananhu@huawei.com>
-----------------------------------------------------------------------------------------
--- a/drivers/net/ppp_async.c	2009-10-12 05:43:56.000000000 +0800
+++ b/drivers/net/ppp_async.c	2009-10-15 16:29:56.000000000 +0800
@@ -36,7 +36,7 @@
 
 #define PPP_VERSION	"2.4.2"
 
-#define OBUFSIZE	256
+#define OBUFSIZE	2048
 
 /* Structure for storing local state. */
 struct asyncppp {

******************************************************************************************
 This email and its attachments contain confidential information from HUAWEI, which is intended only for the person or entity whose address is listed above. Any use of the information contained here in any way (including, but not limited to, total or partial disclosure, reproduction, or dissemination) by persons other than the intended recipient(s) is prohibited. If you receive this email in error, please notify the sender by phone or email
 immediately and delete it!
 *****************************************************************************************
