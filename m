From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2 net-next 0/3] net: stmmac: adding multiple buffers and routing
Date: Fri, 17 Mar 2017 16:11:04 +0000
Message-ID: <cover.1489766674.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:46981 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdCQQSm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 12:18:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As agreed with David Miller, this patch-set is the third and last to enable
multiple queues in stmmac.

This third one focuses on:

a) Enable multiple buffering to the driver and queue independent data
b) Configuration of RX and TX queues' priority
c) Configuration of RX queues' routing

Joao Pinto (3):
  net: stmmac: enable multiple buffers
  net: stmmac: TX and RX queue priority configuration
  net: stmmac: RX queue routing configuration

 Documentation/devicetree/bindings/net/stmmac.txt   |   11 +
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |   45 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   21 +
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |   29 +
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  |   71 +
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |   46 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   49 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 1379 ++++++++++++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    7 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   30 +
 include/linux/stmmac.h                             |    5 +
 11 files changed, 1220 insertions(+), 473 deletions(-)

-- 
2.9.3
