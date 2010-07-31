From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 24/29] LMC: Remove unused variables.
Date: Sat, 31 Jul 2010 17:05:47 +0200
Message-ID: <1280588752-9340-24-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:59352 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756559Ab0GaPGX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:23 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/var.h |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index 93c21fe..206f77a 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -272,15 +272,9 @@ struct card {
 	struct lmc_extra_statistics extra_stats;
 	struct net_device *netdev;
=20
-	int hang, rxdesc, bad_packet, some_counter;
-	u32 txgo;
 	struct lmc_regfile_t csrs;
-	volatile u32 txtick;
-	volatile u32 rxtick;
-	u32 flags;
 	u32 intrmask;		/* our copy of csr_intr */
 	u32 cmdmode;		/* our copy of csr_cmdmode */
-	u32 busmode;		/* our copy of csr_busmode */
 	u32 gpio_io;		/* state of in/out settings */
 	u32 gpio;		/* state of outputs */
 	struct sk_buff *txq[LMC_TXDESCS];
@@ -289,12 +283,10 @@ struct card {
 	volatile struct tulip_desc_t txring[LMC_TXDESCS];
 	unsigned int next_rx, next_tx;
 	volatile unsigned int taint_tx, taint_rx;
-	int tx_start, txfull;
-	int txbusy;
+	int txfull;
 	u16 miireg16;
 	int ok;
 	int last_link_status;
-	u32 last_frameerr;
 	struct media *media;
 	struct timer_list timer;
 	struct control ictl;
@@ -304,18 +296,13 @@ struct card {
 	int tx_TimeoutDisplay;
 	unsigned int last_taint_tx;
 	int lasttx_packets;
-	u32 tx_clockState;
 	u32 crcSize;
 	LMC_XINFO xinfo;
-	char yel, blue, red; /* for T1 and DS3 */
 	char timing;		/* for HSSI and SSI */
 	int got_irq;
=20
 	char last_led_err[4];
=20
-	u32 last_int;
-	u32 num_int;
-
 	spinlock_t lock;
=20
 	u8 failed_ring;			/* Failure cases */
--=20
1.7.1.1

