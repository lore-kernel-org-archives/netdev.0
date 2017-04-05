From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 0/4 v2 net-next] net: stmmac: adding multiple buffers
Date: Wed,  5 Apr 2017 17:43:00 +0100
Message-ID: <cover.1491409859.git.jpinto@synopsys.com>
Cc: netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net, clabbe.montjoie@gmail.com, treding@nvidia.com,
        niklas.cassel@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:60664 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755710AbdDEQnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 12:43:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds multiple buffers to stmmac in a more fragmented
way, in order to make problem debug easier.

I would kindly request to people to test this patch in their HWs in
order to check if everything's functional. Thank you.

Joao Pinto (4):
  net: stmmac: break some functions into RX and TX scopes
  net: stmmac: adding multiple buffers for RX
  net: stmmac: adding multiple buffers for TX
  net: stmmac: adding multiple napi mechanism

 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |   45 +-
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |   46 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   49 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 1257 ++++++++++++++-------
 4 files changed, 947 insertions(+), 450 deletions(-)

-- 
2.9.3
