From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 0/2] get rid of immrbar_virt_to_phys()
Date: Tue,  7 Feb 2017 10:05:07 +0100 (CET)
Message-ID: <cover.1486456900.git.christophe.leroy@c-s.fr>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Li Yang <leoli@freescale.com>, Qiang Zhao <qiang.zhao@nxp.com>,
        Scott Wood <oss@buserror.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ucc_geth ethernet driver is the only driver using immrbar_virt_to_phys() and it uses it incorrectly.

This patch fixes ucc_geth driver then removes immrbar_virt_to_phys()

Christophe Leroy (2):
  net: ethernet: ucc_geth: fix MEM_PART_MURAM mode
  soc/fsl/qe: get rid of immrbar_virt_to_phys()

 drivers/net/ethernet/freescale/ucc_geth.c |  8 +++-----
 drivers/soc/fsl/qe/qe.c                   |  4 +---
 include/soc/fsl/qe/immap_qe.h             | 19 -------------------
 include/soc/fsl/qe/qe.h                   |  1 +
 4 files changed, 5 insertions(+), 27 deletions(-)

-- 
2.10.1
