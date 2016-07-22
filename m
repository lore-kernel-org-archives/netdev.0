From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] libcxgb: remove unused including <linux/version.h>
Date: Fri, 22 Jul 2016 14:05:32 +0000
Message-ID: <1469196332-17472-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Nicholas Bellinger <nab@linux-iscsi.org>,
	Varun Prakash <varun@chelsio.com>,
	Steve Wise <swise@opengridcomputing.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35781 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbcGVOFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 10:05:41 -0400
Received: by mail-pa0-f66.google.com with SMTP id cf3so7023863pad.2
        for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 07:05:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove including <linux/version.h> that don't need it.

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
index 96c9651..1074fdb 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
@@ -39,7 +39,6 @@
 #define pr_fmt(fmt) DRV_NAME ": " fmt
 
 #include <linux/kernel.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/types.h>
