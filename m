From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH net-next 0/2] net: stmmac: multiple queue fixes
Date: Fri, 24 Mar 2017 17:16:43 +0000
Message-ID: <cover.1490375512.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        clabbe.montjoie@gmail.com, thierry.reding@gmail.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:58441 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965669AbdCXRQv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 13:16:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set contains two fixes for problems I detected when ran the driver
in single queue mode.

Please test in your setups to check if you get better results.

Joao Pinto (2):
  net: stmmac: fix netdev release
  net: stmmac: fix number of tx queues in stmmac_poll

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

-- 
2.9.3
