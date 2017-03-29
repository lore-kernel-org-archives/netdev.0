From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] stmmac: use
 netif_set_real_num_{rx,tx}_queues
Date: Tue, 28 Mar 2017 18:01:05 -0700 (PDT)
Message-ID: <20170328.180105.1996071259325891752.davem@davemloft.net>
References: <20170328094856.3457886-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        Joao.Pinto@synopsys.com, clabbe.montjoie@gmail.com,
        treding@nvidia.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170328094856.3457886-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 28 Mar 2017 11:48:21 +0200

> A driver must not access the two fields directly but should instead use
> the helper functions to set the values and keep a consistent internal
> state:
> 
> ethernet/stmicro/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
> ethernet/stmicro/stmmac/stmmac_main.c:4083:8: error: 'struct net_device' has no member named 'real_num_rx_queues'; did you mean 'real_num_tx_queues'?
> 
> Fixes: a8f5102af2a7 ("net: stmmac: TX and RX queue priority configuration")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
