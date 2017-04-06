From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 0/4 v3 net-next] net: stmmac: adding multiple buffers
Date: Thu,  6 Apr 2017 09:49:07 +0100
Message-ID: <cover.1491467980.git.jpinto@synopsys.com>
Cc: netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net, clabbe.montjoie@gmail.com, treding@nvidia.com,
        niklas.cassel@axis.com, julia.lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:57652 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754309AbdDFItR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 04:49:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds multiple buffers to stmmac in a more fragmented
way, in order to make problem debug easier.

I would kindly request to people to test this patch in their HWs in
order to check if everything's functional. Thank you.

Joao Pinto (4):
  net: stmmac: break some functions into RX and TX scopes
  net: stmmac: adding multiple buffers for rx
  net: stmmac: adding multiple buffers for TX
  net: stmmac: adding multiple napi mechanism

 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |   45 +-
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |   46 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   49 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 1260 ++++++++++++++-------
 4 files changed, 950 insertions(+), 450 deletions(-)

-- 
2.9.3
