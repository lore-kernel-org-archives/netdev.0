From: frank.blaschka@de.ibm.com
Subject: [patch 2/7] lcs: replace PTR_RET with PTR_ERR_OR_ZERO
Date: Mon, 28 Apr 2014 10:05:06 +0200
Message-ID: <20140428080532.962369412@de.ibm.com>
References: <20140428080504.925649066@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:36869 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753986AbaD1IFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 04:05:38 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 28 Apr 2014 09:05:37 +0100
Content-Disposition: inline; filename=601-lcs-ptr-ret.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

PTR_RET is deprecated. Do not recommend its usage anymore.
Use PTR_ERR_OR_ZERO instead.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/lcs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index c461f2a..8d5d969 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -2442,7 +2442,7 @@ __init lcs_init_module(void)
 	if (rc)
 		goto out_err;
 	lcs_root_dev = root_device_register("lcs");
-	rc = PTR_RET(lcs_root_dev);
+	rc = PTR_ERR_OR_ZERO(lcs_root_dev);
 	if (rc)
 		goto register_err;
 	rc = ccw_driver_register(&lcs_ccw_driver);
