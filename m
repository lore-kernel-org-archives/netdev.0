From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 6/6] mISDN: cleanup mISDNhw.h
Date: Thu, 11 Jun 2009 15:52:10 +0200
Message-ID: <670025478c2a687453cd1bac697d7d765843f59d.1244739994.git.keil@b1-systems.de>
References: <cover.1244739994.git.keil@b1-systems.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755975AbZFKR36@vger.kernel.org>
In-Reply-To: <cover.1244739994.git.keil@b1-systems.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unused stuff.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 include/linux/mISDNhw.h |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/include/linux/mISDNhw.h b/include/linux/mISDNhw.h
index ce900f4..7f9831d 100644
--- a/include/linux/mISDNhw.h
+++ b/include/linux/mISDNhw.h
@@ -89,11 +89,6 @@ struct dchannel {
 	void			(*phfunc) (struct dchannel *);
 	u_int			state;
 	void			*l1;
-	/* HW access */
-	u_char			(*read_reg) (void *, u_char);
-	void			(*write_reg) (void *, u_char, u_char);
-	void			(*read_fifo) (void *, u_char *, int);
-	void			(*write_fifo) (void *, u_char *, int);
 	void			*hw;
 	int			slot;	/* multiport card channel slot */
 	struct timer_list	timer;
@@ -151,11 +146,6 @@ struct bchannel {
 	u_long			Flags;
 	struct work_struct	workq;
 	u_int			state;
-	/* HW access */
-	u_char			(*read_reg) (void *, u_char);
-	void			(*write_reg) (void *, u_char, u_char);
-	void			(*read_fifo) (void *, u_char *, int);
-	void			(*write_fifo) (void *, u_char *, int);
 	void			*hw;
 	int			slot;	/* multiport card channel slot */
 	struct timer_list	timer;
-- 
1.6.0.2
