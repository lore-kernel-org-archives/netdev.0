From: Jose Abreu <Jose.Abreu@synopsys.com>
Subject: [PATCH net-next 0/3] net: stmmac: Fix HW timestamping
Date: Fri, 20 Oct 2017 14:37:33 +0100
Message-ID: <cover.1508506265.git.joabreu@synopsys.com>
Cc: Jose Abreu <Jose.Abreu@synopsys.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Three fixes for HW timestamping feature, all of them for RX side.

Best regards,
Jose Miguel Abreu

David,

I'm targeting this for -next but teel free to apply this in
your -fixes tree if you think its needed. Though, I don't
think anyone is using HW timestamping because these bugs would
appear immediatly.

Cc: David S. Miller <davem@davemloft.net>
Cc: Joao Pinto <jpinto@synopsys.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>

Jose Abreu (3):
  net: stmmac: Add missing call to dev_kfree_skb()
  net: stmmac: Fix stmmac_get_rx_hwtstamp()
  net: stmmac: Prevent infinite loop in get_rx_timestamp_status()

 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)

-- 
1.9.1
