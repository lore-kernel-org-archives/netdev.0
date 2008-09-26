From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/2] qlge: Fix warnings in debugging code.
Date: Fri, 26 Sep 2008 15:25:25 -0700
Message-ID: <1222467926-19164-1-git-send-email-ron.mercer@qlogic.com>
References: <20080926222434.GA19152@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com, David Miller <davem@davemloft.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:38405 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbYIZWZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 18:25:40 -0400
In-Reply-To: <20080926222434.GA19152@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Miller <davem@davemloft.net>

qlge: Fix warnings in debugging code.

drivers/net/qlge/qlge_dbg.c: In function =E2=80=98ql_dump_qdev=E2=80=99=
:
drivers/net/qlge/qlge_dbg.c:369: warning: cast to pointer from integer =
of different size
drivers/net/qlge/qlge_dbg.c:373: warning: cast to pointer from integer =
of different size
drivers/net/qlge/qlge_dbg.c: In function =E2=80=98ql_dump_tx_ring=E2=80=
=99:
drivers/net/qlge/qlge_dbg.c:457: warning: format =E2=80=98%llx=E2=80=99=
 expects type =E2=80=98long long unsigned int=E2=80=99, but argument 2 =
has type =E2=80=98long unsigned int=E2=80=99
drivers/net/qlge/qlge_dbg.c:461: warning: format =E2=80=98%llx=E2=80=99=
 expects type =E2=80=98long long unsigned int=E2=80=99, but argument 2 =
has type =E2=80=98long unsigned int=E2=80=99
drivers/net/qlge/qlge_dbg.c: In function =E2=80=98ql_dump_rx_ring=E2=80=
=99:
drivers/net/qlge/qlge_dbg.c:557: warning: format =E2=80=98%llx=E2=80=99=
 expects type =E2=80=98long long unsigned int=E2=80=99, but argument 2 =
has type =E2=80=98long unsigned int=E2=80=99
drivers/net/qlge/qlge_dbg.c:565: warning: format =E2=80=98%llx=E2=80=99=
 expects type =E2=80=98long long unsigned int=E2=80=99, but argument 2 =
has type =E2=80=98long unsigned int=E2=80=99
drivers/net/qlge/qlge_dbg.c:575: warning: format =E2=80=98%llx=E2=80=99=
 expects type =E2=80=98long long unsigned int=E2=80=99, but argument 2 =
has type =E2=80=98long unsigned int=E2=80=99
drivers/net/qlge/qlge_dbg.c:579: warning: format =E2=80=98%llx=E2=80=99=
 expects type =E2=80=98long long unsigned int=E2=80=99, but argument 2 =
has type =E2=80=98long unsigned int=E2=80=99
drivers/net/qlge/qlge_dbg.c:598: warning: format =E2=80=98%llx=E2=80=99=
 expects type =E2=80=98long long unsigned int=E2=80=99, but argument 2 =
has type =E2=80=98long unsigned int=E2=80=99
drivers/net/qlge/qlge_dbg.c:602: warning: format =E2=80=98%llx=E2=80=99=
 expects type =E2=80=98long long unsigned int=E2=80=99, but argument 2 =
has type =E2=80=98long unsigned int=E2=80=99

Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_dbg.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index f0392b1..47df304 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -365,12 +365,12 @@ void ql_dump_qdev(struct ql_adapter *qdev)
 	       qdev->msg_enable);
 	printk(KERN_ERR PFX "qdev->rx_ring_shadow_reg_area	=3D %p.\n",
 	       qdev->rx_ring_shadow_reg_area);
-	printk(KERN_ERR PFX "qdev->rx_ring_shadow_reg_dma 	=3D %p.\n",
-	       (void *)qdev->rx_ring_shadow_reg_dma);
+	printk(KERN_ERR PFX "qdev->rx_ring_shadow_reg_dma 	=3D %llx.\n",
+	       (unsigned long long) qdev->rx_ring_shadow_reg_dma);
 	printk(KERN_ERR PFX "qdev->tx_ring_shadow_reg_area	=3D %p.\n",
 	       qdev->tx_ring_shadow_reg_area);
-	printk(KERN_ERR PFX "qdev->tx_ring_shadow_reg_dma	=3D %p.\n",
-	       (void *)qdev->tx_ring_shadow_reg_dma);
+	printk(KERN_ERR PFX "qdev->tx_ring_shadow_reg_dma	=3D %llx.\n",
+	       (unsigned long long) qdev->tx_ring_shadow_reg_dma);
 	printk(KERN_ERR PFX "qdev->intr_count 		=3D %d.\n",
 	       qdev->intr_count);
 	if (qdev->msi_x_entry)
@@ -454,11 +454,11 @@ void ql_dump_tx_ring(struct tx_ring *tx_ring)
 	       tx_ring->wq_id);
 	printk(KERN_ERR PFX "tx_ring->base =3D %p.\n", tx_ring->wq_base);
 	printk(KERN_ERR PFX "tx_ring->base_dma =3D 0x%llx.\n",
-	       (u64) tx_ring->wq_base_dma);
+	       (unsigned long long) tx_ring->wq_base_dma);
 	printk(KERN_ERR PFX "tx_ring->cnsmr_idx_sh_reg =3D %p.\n",
 	       tx_ring->cnsmr_idx_sh_reg);
 	printk(KERN_ERR PFX "tx_ring->cnsmr_idx_sh_reg_dma =3D 0x%llx.\n",
-	       (u64) tx_ring->cnsmr_idx_sh_reg_dma);
+	       (unsigned long long) tx_ring->cnsmr_idx_sh_reg_dma);
 	printk(KERN_ERR PFX "tx_ring->size =3D %d.\n", tx_ring->wq_size);
 	printk(KERN_ERR PFX "tx_ring->len =3D %d.\n", tx_ring->wq_len);
 	printk(KERN_ERR PFX "tx_ring->prod_idx_db_reg =3D %p.\n",
@@ -554,7 +554,7 @@ void ql_dump_rx_ring(struct rx_ring *rx_ring)
 	printk(KERN_ERR PFX "rx_ring->cqicb =3D %p.\n", &rx_ring->cqicb);
 	printk(KERN_ERR PFX "rx_ring->cq_base =3D %p.\n", rx_ring->cq_base);
 	printk(KERN_ERR PFX "rx_ring->cq_base_dma =3D %llx.\n",
-	       (u64) rx_ring->cq_base_dma);
+	       (unsigned long long) rx_ring->cq_base_dma);
 	printk(KERN_ERR PFX "rx_ring->cq_size =3D %d.\n", rx_ring->cq_size);
 	printk(KERN_ERR PFX "rx_ring->cq_len =3D %d.\n", rx_ring->cq_len);
 	printk(KERN_ERR PFX
@@ -562,7 +562,7 @@ void ql_dump_rx_ring(struct rx_ring *rx_ring)
 	       rx_ring->prod_idx_sh_reg,
 	       rx_ring->prod_idx_sh_reg ? *(rx_ring->prod_idx_sh_reg) : 0);
 	printk(KERN_ERR PFX "rx_ring->prod_idx_sh_reg_dma =3D %llx.\n",
-	       (u64) rx_ring->prod_idx_sh_reg_dma);
+	       (unsigned long long) rx_ring->prod_idx_sh_reg_dma);
 	printk(KERN_ERR PFX "rx_ring->cnsmr_idx_db_reg =3D %p.\n",
 	       rx_ring->cnsmr_idx_db_reg);
 	printk(KERN_ERR PFX "rx_ring->cnsmr_idx =3D %d.\n", rx_ring->cnsmr_id=
x);
@@ -572,11 +572,11 @@ void ql_dump_rx_ring(struct rx_ring *rx_ring)
=20
 	printk(KERN_ERR PFX "rx_ring->lbq_base =3D %p.\n", rx_ring->lbq_base)=
;
 	printk(KERN_ERR PFX "rx_ring->lbq_base_dma =3D %llx.\n",
-	       (u64) rx_ring->lbq_base_dma);
+	       (unsigned long long) rx_ring->lbq_base_dma);
 	printk(KERN_ERR PFX "rx_ring->lbq_base_indirect =3D %p.\n",
 	       rx_ring->lbq_base_indirect);
 	printk(KERN_ERR PFX "rx_ring->lbq_base_indirect_dma =3D %llx.\n",
-	       (u64) rx_ring->lbq_base_indirect_dma);
+	       (unsigned long long) rx_ring->lbq_base_indirect_dma);
 	printk(KERN_ERR PFX "rx_ring->lbq =3D %p.\n", rx_ring->lbq);
 	printk(KERN_ERR PFX "rx_ring->lbq_len =3D %d.\n", rx_ring->lbq_len);
 	printk(KERN_ERR PFX "rx_ring->lbq_size =3D %d.\n", rx_ring->lbq_size)=
;
@@ -595,11 +595,11 @@ void ql_dump_rx_ring(struct rx_ring *rx_ring)
=20
 	printk(KERN_ERR PFX "rx_ring->sbq_base =3D %p.\n", rx_ring->sbq_base)=
;
 	printk(KERN_ERR PFX "rx_ring->sbq_base_dma =3D %llx.\n",
-	       (u64) rx_ring->sbq_base_dma);
+	       (unsigned long long) rx_ring->sbq_base_dma);
 	printk(KERN_ERR PFX "rx_ring->sbq_base_indirect =3D %p.\n",
 	       rx_ring->sbq_base_indirect);
 	printk(KERN_ERR PFX "rx_ring->sbq_base_indirect_dma =3D %llx.\n",
-	       (u64) rx_ring->sbq_base_indirect_dma);
+	       (unsigned long long) rx_ring->sbq_base_indirect_dma);
 	printk(KERN_ERR PFX "rx_ring->sbq =3D %p.\n", rx_ring->sbq);
 	printk(KERN_ERR PFX "rx_ring->sbq_len =3D %d.\n", rx_ring->sbq_len);
 	printk(KERN_ERR PFX "rx_ring->sbq_size =3D %d.\n", rx_ring->sbq_size)=
;
--=20
1.6.0

