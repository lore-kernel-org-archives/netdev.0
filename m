From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: ndo_set_config/ifmap cleanups
Date: Mon, 21 Apr 2014 09:09:18 -0700
Message-ID: <1398096563-8786-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bh74.an@samsung.com, ks.giri@samsung.com,
	siva.kallam@samsung.com, peppe.cavallaro@st.com,
	jcmvbkbc@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:59294 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbaDUQJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 12:09:35 -0400
Received: by mail-qa0-f41.google.com with SMTP id j5so3977257qaq.14
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 09:09:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series removes a bunch of useless ndo_set_config in non
PCMCIA Ethernet drivers.

Florian Fainelli (4):
  net: ethoc: remove ethoc_config
  net: cpmac: remove cpmac_config
  net: sxgbe: remove sxgbe_config
  stmmac: remove stmmac_config

 drivers/net/ethernet/ethoc.c                      |  6 ----
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c   | 35 -----------------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 22 --------------
 drivers/net/ethernet/ti/cpmac.c                   | 14 ---------
 4 files changed, 77 deletions(-)

-- 
1.9.1
