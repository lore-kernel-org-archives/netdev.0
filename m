From: frank.blaschka@de.ibm.com
Subject: [patch 7/7] ctc: replace PTR_RET with PTR_ERR_OR_ZERO
Date: Mon, 28 Apr 2014 10:05:11 +0200
Message-ID: <20140428080533.562193862@de.ibm.com>
References: <20140428080504.925649066@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:54611 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753308AbaD1IFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 04:05:38 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 28 Apr 2014 09:05:36 +0100
Content-Disposition: inline; filename=ctc-ptr-ret.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

PTR_RET is deprecated. Do not recommend its usage anymore.
Use PTR_ERR_OR_ZERO instead.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/ctcm_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/s390/net/ctcm_main.c
+++ b/drivers/s390/net/ctcm_main.c
@@ -1837,7 +1837,7 @@ static int __init ctcm_init(void)
 	if (ret)
 		goto out_err;
 	ctcm_root_dev = root_device_register("ctcm");
-	ret = PTR_RET(ctcm_root_dev);
+	ret = PTR_ERR_OR_ZERO(ctcm_root_dev);
 	if (ret)
 		goto register_err;
 	ret = ccw_driver_register(&ctcm_ccw_driver);
