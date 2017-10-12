From: Jose Abreu <Jose.Abreu@synopsys.com>
Subject: [PATCH net-next 0/2] net: stmmac: Improvements for multi-queuing and for AVB
Date: Thu, 12 Oct 2017 16:14:40 +0100
Message-ID: <cover.1507820933.git.joabreu@synopsys.com>
Cc: Jose Abreu <Jose.Abreu@synopsys.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:36630 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751394AbdJLPPK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 11:15:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Two improvements for stmmac: First one corrects the available fifo size per queue, second one corrects enabling of AVB queues. More info in commit log.

Best regards,
Jose Miguel Abreu

Cc: David S. Miller <davem@davemloft.net>
Cc: Joao Pinto <jpinto@synopsys.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>

Jose Abreu (2):
  net: stmmac: Use correct values in TQS/RQS fields
  net: stmmac: Disable flow ctrl for RX AVB queues and really enable TX
    AVB queues

 drivers/net/ethernet/stmicro/stmmac/common.h      |  5 +--
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h      |  2 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c  | 27 ++++++++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 39 +++++++++++++++++++----
 4 files changed, 56 insertions(+), 17 deletions(-)

-- 
1.9.1
