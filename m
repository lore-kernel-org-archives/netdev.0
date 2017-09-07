From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 2/7] net: qrtr: Move constants to header file
Date: Wed,  6 Sep 2017 23:03:24 -0700
Message-ID: <20170907060329.32402-3-bjorn.andersson@linaro.org>
References: <20170907060329.32402-1-bjorn.andersson@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, Chris Lew <clew@codeaurora.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:38649 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753942AbdIGGDg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 02:03:36 -0400
Received: by mail-pg0-f50.google.com with SMTP id v66so19132023pgb.5
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 23:03:36 -0700 (PDT)
In-Reply-To: <20170907060329.32402-1-bjorn.andersson@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The constants are used by both the name server and clients, so clarify
their value and move them to the uapi header.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 include/uapi/linux/qrtr.h | 3 +++
 net/qrtr/qrtr.c           | 2 --
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/qrtr.h b/include/uapi/linux/qrtr.h
index 9d76c566f66e..63e8803e4d90 100644
--- a/include/uapi/linux/qrtr.h
+++ b/include/uapi/linux/qrtr.h
@@ -4,6 +4,9 @@
 #include <linux/socket.h>
 #include <linux/types.h>
 
+#define QRTR_NODE_BCAST	0xffffffffu
+#define QRTR_PORT_CTRL	0xfffffffeu
+
 struct sockaddr_qrtr {
 	__kernel_sa_family_t sq_family;
 	__u32 sq_node;
diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index 2058b27821a4..0d7d3968414e 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -61,8 +61,6 @@ struct qrtr_hdr {
 } __packed;
 
 #define QRTR_HDR_SIZE sizeof(struct qrtr_hdr)
-#define QRTR_NODE_BCAST ((unsigned int)-1)
-#define QRTR_PORT_CTRL ((unsigned int)-2)
 
 struct qrtr_sock {
 	/* WARNING: sk must be the first member */
-- 
2.12.0
