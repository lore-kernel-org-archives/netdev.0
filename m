From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/qla3xxx.c: make 2 functions static
Date: Mon, 5 Mar 2007 02:49:27 +0100
Message-ID: <20070305014927.GY3441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org
To: linux-driver@qlogic.com, Ron Mercer <ron.mercer@qlogic.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751677AbXCEBx6@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes two needlessly global functions static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---
--- linux-2.6.21-rc2-mm1/drivers/net/qla3xxx.c.old	2007-03-04 21:41:27.000000000 +0100
+++ linux-2.6.21-rc2-mm1/drivers/net/qla3xxx.c	2007-03-04 21:41:39.000000000 +0100
@@ -1797,14 +1797,14 @@
 	atomic_inc(&qdev->tx_count);
 }
 
-void ql_get_sbuf(struct ql3_adapter *qdev)
+static void ql_get_sbuf(struct ql3_adapter *qdev)
 {
 	if (++qdev->small_buf_index == NUM_SMALL_BUFFERS)
 		qdev->small_buf_index = 0;
 	qdev->small_buf_release_cnt++;
 }
 
-struct ql_rcv_buf_cb *ql_get_lbuf(struct ql3_adapter *qdev)
+static struct ql_rcv_buf_cb *ql_get_lbuf(struct ql3_adapter *qdev)
 {
 	struct ql_rcv_buf_cb *lrg_buf_cb = NULL;
 	lrg_buf_cb = &qdev->lrg_buf[qdev->lrg_buf_index];
