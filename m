From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 0/4] stmmac: probe code refactoring and clean up part 1
Date: Wed, 20 May 2015 20:03:05 +0200
Message-ID: <1432144989-28283-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, arnd@arndb.de,
	linux-arm-kernel@lists.infradead.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:36541 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752851AbbETSD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 14:03:29 -0400
Received: by lagv1 with SMTP id v1so85677092lag.3
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:03:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set refactor the code in stmmac_pci_probe and stmmac_pltfr_probe
and moves the common bits into stmmac_dvr_probe. Along the way some clean-
ups are applied to stmmac_pltfr_probe.

The code has been tested on the LPC18xx platform.

I am still working on more refactoring of the platform probe code, hence
part 1, but I need some more time on this.


Joachim Eastwood (4):
  stmmac: move driver data setting into stmmac_dvr_probe
  stmmac: let stmmac_dvr_probe take a struct of resources
  stmmac: change the stmmac_dvr_probe return type to int
  stmmac: drop unnecessary dt checks in stmmac_probe_config_dt

 drivers/net/ethernet/stmicro/stmmac/stmmac.h       | 14 +++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 30 +++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   | 19 +++----
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 62 +++++++---------------
 4 files changed, 54 insertions(+), 71 deletions(-)

-- 
1.8.0
