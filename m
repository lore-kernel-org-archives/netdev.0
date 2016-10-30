From: Joachim Eastwood <manabian@gmail.com>
Subject: [net-next PATCH 0/7] stmmac: dwmac-sti refactor+cleanup
Date: Sun, 30 Oct 2016 21:05:00 +0100
Message-ID: <20161030200507.851-1-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36417 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752842AbcJ3UGc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 16:06:32 -0400
Received: by mail-lf0-f67.google.com with SMTP id o20so433600lfg.3
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 13:06:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set aims to remove the init/exit callbacks from the 
dwmac-sti driver and instead use standard PM callbacks. Doing this
will also allow us to cleanup the driver.

Eventually the init/exit callbacks will be deprecated and removed
from all drivers dwmac-* except for dwmac-generic. Drivers will be
refactored to use standard PM and remove callbacks.

Note that this patch set has only been test compiled and no functional
change is intended.

Joachim Eastwood (7):
  stmmac: dwmac-sti: remove useless of_node check
  stmmac: dwmac-sti: remove clk NULL checks
  stmmac: dwmac-sti: add PM ops and resume function
  stmmac: dwmac-sti: move st,gmac_en parsing to sti_dwmac_parse_data
  stmmac: dwmac-sti: move clk_prepare_enable out of init and add error handling
  stmmac: dwmac-sti: clean up and rename sti_dwmac_init
  stmmac: dwmac-sti: remove unused priv dev member

 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 86 ++++++++++++++++---------
 1 file changed, 57 insertions(+), 29 deletions(-)

-- 
2.10.1
