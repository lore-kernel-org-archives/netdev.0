From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH drivers/net/skfp/h/fplustm.h] parentheses around RX_FIFO_SPACE
 definition
Date: Mon, 17 Dec 2007 22:55:16 +0100
Message-ID: <4766F044.8090302@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out0.tiscali.nl ([195.241.79.175]:54575 "EHLO
	smtp-out0.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755673AbXLQVzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 16:55:20 -0500
Received: from [82.171.216.234] (helo=[192.168.1.2])
	by smtp-out0.tiscali.nl with esmtp (Tiscali http://www.tiscali.nl)
	id 1J4Nvh-0002xo-Nm
	for <netdev@vger.kernel.org>; Mon, 17 Dec 2007 22:55:17 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/skfp/h/fplustm.h:129:
#define RX_FIFO_SPACE           0x4000 - RX_FIFO_OFF

drivers/net/skfp/fplustm.c:1404:
                smc->hw.fp.fifo.rx1_fifo_size = RX_FIFO_SPACE *
                SMT_R1_RXD_COUNT/(SMT_R1_RXD_COUNT+SMT_R2_RXD_COUNT) ;
                smc->hw.fp.fifo.rx2_fifo_size = RX_FIFO_SPACE *
                SMT_R2_RXD_COUNT/(SMT_R1_RXD_COUNT+SMT_R2_RXD_COUNT) ;

Add parentheses to definition to prevent operator precedence errors

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/net/skfp/h/fplustm.h b/drivers/net/skfp/h/fplustm.h
index 98bbf65..588579c 100644
--- a/drivers/net/skfp/h/fplustm.h
+++ b/drivers/net/skfp/h/fplustm.h
@@ -126,7 +126,7 @@ struct s_smt_rx_queue {
 #define	SYNC_TRAFFIC_ON		0x2
 
 /* big FIFO memory */
-#define	RX_FIFO_SPACE		0x4000 - RX_FIFO_OFF
+#define	RX_FIFO_SPACE		(0x4000 - RX_FIFO_OFF)
 #define	TX_FIFO_SPACE		0x4000
 
 #define	TX_SMALL_FIFO		0x0900
