From: Quentin Lambert <lambert.quentin@gmail.com>
Subject: [PATCH 2/2] linux/interrupt.h: remove the definition of unused
 tasklet_hi_enable
Date: Fri, 12 Dec 2014 13:36:54 +0100
Message-ID: <20141212123654.GA12811@sloth>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Quentin Lambert <lambert.quentin@gmail.com>
Signed-off-by: Valentin Rothberg <valentinrothberg@gmail.com>
---
 include/linux/interrupt.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 69517a2..d9b05b5 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -556,12 +556,6 @@ static inline void tasklet_enable(struct tasklet_struct *t)
 	atomic_dec(&t->count);
 }
 
-static inline void tasklet_hi_enable(struct tasklet_struct *t)
-{
-	smp_mb__before_atomic();
-	atomic_dec(&t->count);
-}
-
 extern void tasklet_kill(struct tasklet_struct *t);
 extern void tasklet_kill_immediate(struct tasklet_struct *t, unsigned int cpu);
 extern void tasklet_init(struct tasklet_struct *t,
-- 
1.9.1
