From: weiyj_lk@163.com
Subject: [PATCH] net:liquidio: remove unused including <linux/version.h>
Date: Fri, 17 Jun 2016 17:49:33 +0000
Message-ID: <1466185773-17644-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:60828 "EHLO m12-12.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751087AbcFQRt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 13:49:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove including <linux/version.h> that don't need it.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/cavium/liquidio/octeon_device.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 8e23e3f..ba04375 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -19,7 +19,6 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
-#include <linux/version.h>
 #include <linux/types.h>
 #include <linux/list.h>
 #include <linux/interrupt.h>
