From: Tingwei Liu <tingw.liu@gmail.com>
Subject: [PATCH] 9P: Add cancelled to p9_rdma_trans
Date: Mon, 15 Jul 2013 17:10:41 +0800
Message-ID: <1373879441-28327-1-git-send-email-tingw.liu@gmail.com>
To: simon.derr@bull.net, tingw.liu@gmail.com, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:37555 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754434Ab3GOJMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 05:12:02 -0400
Received: by mail-pd0-f179.google.com with SMTP id q10so10488771pdj.38
        for <netdev@vger.kernel.org>; Mon, 15 Jul 2013 02:12:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 net/9p/trans_rdma.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 928f2bb..0c42b1c 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -732,6 +732,7 @@ static struct p9_trans_module p9_rdma_trans = {
 	.close = rdma_close,
 	.request = rdma_request,
 	.cancel = rdma_cancel,
+	.cancelled = rdma_cancelled,
 };
 
 /**
-- 
1.6.0.2
