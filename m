From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH 0/3] net: stmmac: Fixes and cleanups in 'alloc_dma_[rt]x_desc_resources()'
Date: Sat,  8 Jul 2017 09:46:12 +0200
Message-ID: <cover.1499499451.git.christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patchs are all related to 'alloc_dma_[rt]x_desc_resources()' functions.

The 2 first fix an error path where some resources are leaking. I've
separated them into 2 patches because the issues have been introduced by
2 deferent commits.

The 3rd patch is just a clean-up.

Christophe JAILLET (3):
  net: stmmac: Fix error handling path in
    'alloc_dma_rx_desc_resources()'
  net: stmmac: Fix error handling path in
    'alloc_dma_tx_desc_resources()'
  net: stmmac: Make 'alloc_dma_[rt]x_desc_resources()' look even closer

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

-- 
2.11.0

