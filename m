From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] qlge: make local function static
Date: Thu, 26 Dec 2013 10:28:11 -0800
Message-ID: <20131226102811.18758740@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:56479 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753629Ab3LZS2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 13:28:15 -0500
Received: by mail-pb0-f54.google.com with SMTP id un15so8402462pbc.41
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 10:28:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 drivers/net/ethernet/qlogic/qlge/qlge.h     |    1 -
 drivers/net/ethernet/qlogic/qlge/qlge_dbg.c |    4 ++--
 2 files changed, 2 insertions(+), 3 deletions(-)

--- a/drivers/net/ethernet/qlogic/qlge/qlge.h	2013-12-24 15:14:54.434175464 -0800
+++ b/drivers/net/ethernet/qlogic/qlge/qlge.h	2013-12-24 15:16:02.237264497 -0800
@@ -2248,7 +2248,6 @@ int ql_mb_get_port_cfg(struct ql_adapter
 int ql_mb_set_port_cfg(struct ql_adapter *qdev);
 int ql_wait_fifo_empty(struct ql_adapter *qdev);
 void ql_get_dump(struct ql_adapter *qdev, void *buff);
-void ql_gen_reg_dump(struct ql_adapter *qdev, struct ql_reg_dump *mpi_coredump);
 netdev_tx_t ql_lb_send(struct sk_buff *skb, struct net_device *ndev);
 void ql_check_lb_frame(struct ql_adapter *, struct sk_buff *);
 int ql_own_firmware(struct ql_adapter *qdev);
--- a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c	2013-12-24 15:14:54.434175464 -0800
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c	2013-12-24 15:16:02.237264497 -0800
@@ -1242,8 +1242,8 @@ static void ql_get_core_dump(struct ql_a
 	ql_queue_fw_error(qdev);
 }
 
-void ql_gen_reg_dump(struct ql_adapter *qdev,
-			struct ql_reg_dump *mpi_coredump)
+static void ql_gen_reg_dump(struct ql_adapter *qdev,
+			    struct ql_reg_dump *mpi_coredump)
 {
 	int i, status;
 
