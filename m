From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/10] fddi/skfp: Remove extern from function prototypes
Date: Tue, 24 Sep 2013 14:10:03 -0700
Message-ID: <d140ad96146b6e7b196c31cbbb0f971845bfd053.1380056108.git.joe@perches.com>
References: <cover.1380056108.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380056108.git.joe@perches.com>
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
 drivers/net/fddi/skfp/h/smc.h | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/fddi/skfp/h/smc.h b/drivers/net/fddi/skfp/h/smc.h
index 3ca308b..bd1166b 100644
--- a/drivers/net/fddi/skfp/h/smc.h
+++ b/drivers/net/fddi/skfp/h/smc.h
@@ -469,20 +469,20 @@ struct s_smc {
 
 extern const struct fddi_addr fddi_broadcast;
 
-extern void all_selection_criteria(struct s_smc *smc);
-extern void card_stop(struct s_smc *smc);
-extern void init_board(struct s_smc *smc, u_char *mac_addr);
-extern int init_fplus(struct s_smc *smc);
-extern void init_plc(struct s_smc *smc);
-extern int init_smt(struct s_smc *smc, u_char * mac_addr);
-extern void mac1_irq(struct s_smc *smc, u_short stu, u_short stl);
-extern void mac2_irq(struct s_smc *smc, u_short code_s2u, u_short code_s2l);
-extern void mac3_irq(struct s_smc *smc, u_short code_s3u, u_short code_s3l);
-extern int pcm_status_twisted(struct s_smc *smc);
-extern void plc1_irq(struct s_smc *smc);
-extern void plc2_irq(struct s_smc *smc);
-extern void read_address(struct s_smc *smc, u_char * mac_addr);
-extern void timer_irq(struct s_smc *smc);
+void all_selection_criteria(struct s_smc *smc);
+void card_stop(struct s_smc *smc);
+void init_board(struct s_smc *smc, u_char *mac_addr);
+int init_fplus(struct s_smc *smc);
+void init_plc(struct s_smc *smc);
+int init_smt(struct s_smc *smc, u_char *mac_addr);
+void mac1_irq(struct s_smc *smc, u_short stu, u_short stl);
+void mac2_irq(struct s_smc *smc, u_short code_s2u, u_short code_s2l);
+void mac3_irq(struct s_smc *smc, u_short code_s3u, u_short code_s3l);
+int pcm_status_twisted(struct s_smc *smc);
+void plc1_irq(struct s_smc *smc);
+void plc2_irq(struct s_smc *smc);
+void read_address(struct s_smc *smc, u_char *mac_addr);
+void timer_irq(struct s_smc *smc);
 
 #endif	/* _SCMECM_ */
 
-- 
1.8.1.2.459.gbcd45b4.dirty
