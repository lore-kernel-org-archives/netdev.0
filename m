From: Joe Perches <joe@perches.com>
Subject: [PATCH 12/12] stp.h: Remove extern from function prototypes
Date: Sun, 22 Sep 2013 10:32:27 -0700
Message-ID: <9d2d9954458b6bc4b4538c883124a76c1bc7aba7.1379870986.git.joe@perches.com>
References: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/stp.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/stp.h b/include/net/stp.h
index ad447f1..3af174d 100644
--- a/include/net/stp.h
+++ b/include/net/stp.h
@@ -8,7 +8,7 @@ struct stp_proto {
 	void		*data;
 };
 
-extern int stp_proto_register(const struct stp_proto *proto);
-extern void stp_proto_unregister(const struct stp_proto *proto);
+int stp_proto_register(const struct stp_proto *proto);
+void stp_proto_unregister(const struct stp_proto *proto);
 
 #endif /* _NET_STP_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
