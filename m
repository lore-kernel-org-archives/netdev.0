From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 0/4] stmmac: dwmac-rk: convert to standard PM/remove functions
Date: Sat,  5 Nov 2016 14:04:48 +0100
Message-ID: <20161105130452.24226-1-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, heiko@sntech.de,
        linux-rockchip@lists.infradead.org, vpalatin@chromium.org,
        peppe.cavallaro@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36315 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752963AbcKENFM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2016 09:05:12 -0400
Received: by mail-lf0-f67.google.com with SMTP id o20so6133150lfg.3
        for <netdev@vger.kernel.org>; Sat, 05 Nov 2016 06:05:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set aims to remove the init/exit callbacks from the 
dwmac-rk driver and instead use standard PM callbacks. Eventually
the init/exit callbacks will be deprecated and removed from all
drivers dwmac-* except for dwmac-generic. Drivers will be refactored
to use standard PM and remove callbacks.

This conversion was pretty straight forward, but it would really nice
if some chromium people could test suspend/resume with this patch set.


Joachim Eastwood (4):
  stmmac: dwmac-rk: turn resume/suspend into standard PM callbacks
  stmmac: dwmac-rk: turn exit into standard driver remove callback
  stmmac: dwmac-rk: absorb rk_gmac_init into probe
  Revert "net: stmmac: allow to split suspend/resume from init/exit callbacks"

 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 89 +++++++++++-----------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  8 +-
 include/linux/stmmac.h                             |  2 -
 3 files changed, 46 insertions(+), 53 deletions(-)

-- 
2.10.2
