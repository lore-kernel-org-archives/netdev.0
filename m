From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH/RESEND] [trivial] sctp : Fix typo in net/sctp/socket.c
Date: Sat, 21 Jan 2012 10:18:01 +0900
Message-ID: <1327108681-1682-1-git-send-email-standby24x7@gmail.com>
Cc: trivial@kernel.org, standby24x7@gmail.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Masanari Iida<standby24x7@gmail.com>

Correct a typo "sctp_setsocktopt_bindx" to "sctp_setsockopt_bindx"
in net/sctp/socket.c
---
 net/sctp/socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 408ebd0..658483e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -970,7 +970,7 @@ SCTP_STATIC int sctp_setsockopt_bindx(struct sock* sk,
 	void *addr_buf;
 	struct sctp_af *af;
 
-	SCTP_DEBUG_PRINTK("sctp_setsocktopt_bindx: sk %p addrs %p"
+	SCTP_DEBUG_PRINTK("sctp_setsockopt_bindx: sk %p addrs %p"
 			  " addrs_size %d opt %d\n", sk, addrs, addrs_size, op);
 
 	if (unlikely(addrs_size <= 0))
-- 
1.7.6.5
