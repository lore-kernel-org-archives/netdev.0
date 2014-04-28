From: frank.blaschka@de.ibm.com
Subject: [patch 3/7] qeth: replace PTR_RET with PTR_ERR_OR_ZERO
Date: Mon, 28 Apr 2014 10:05:07 +0200
Message-ID: <20140428080533.082561298@de.ibm.com>
References: <20140428080504.925649066@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:45796 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754058AbaD1IFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 04:05:39 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 28 Apr 2014 09:05:37 +0100
Content-Disposition: inline; filename=602-qeth-ptr-ret.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

PTR_RET is deprecated. Do not recommend its usage anymore.
Use PTR_ERR_OR_ZERO instead.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 22470a3..f5bd422 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -5824,7 +5824,7 @@ static int __init qeth_core_init(void)
 	if (rc)
 		goto out_err;
 	qeth_core_root_dev = root_device_register("qeth");
-	rc = PTR_RET(qeth_core_root_dev);
+	rc = PTR_ERR_OR_ZERO(qeth_core_root_dev);
 	if (rc)
 		goto register_err;
 	qeth_core_header_cache = kmem_cache_create("qeth_hdr",
