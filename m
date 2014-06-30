From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v2 0/3] net: stmmac: Correct socfpga init/exit and
Date: Sun, 29 Jun 2014 20:34:50 -0500
Message-ID: <1404092093-18630-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com, vbridger@altera.com
To: netdev@vger.kernel.org, davem@davemloft.net, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:61642 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407AbaF3Bir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 21:38:47 -0400
Received: by mail-oa0-f49.google.com with SMTP id i7so8030676oag.36
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2014 18:38:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds platform specific init/exit code so that socfpga
suspend/resume works as expected, and corrects a minor issue detected by
cppcheck. 

---
V2: Address review comments by adding a line break at end of function and
    structure declaration. Add another trivial cppcheck patch.

Vince Bridgers (3):
  net: stmmac: add platform init/exit for Altera's ARM socfpga
  net: stmmac: Correct duplicate if/then/else case found by cppcheck
  net: stmmac: Remove unneeded I/O read caught by cppcheck

 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |   69 ++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |    5 +-
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    4 ++
 4 files changed, 75 insertions(+), 5 deletions(-)

-- 
1.7.9.5
