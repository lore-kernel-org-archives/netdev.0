From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v2 2/7] net: qrtr: Move constants to header file
Date: Tue, 10 Oct 2017 23:45:18 -0700
Message-ID: <20171011064523.7902-3-bjorn.andersson@linaro.org>
References: <20171011064523.7902-1-bjorn.andersson@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, Chris Lew <clew@codeaurora.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011064523.7902-1-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The constants are used by both the name server and clients, so clarify
their value and move them to the uapi header.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---

Changes since v1:
- None

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
index 7e4b49a8349e..15981abc042c 100644
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
