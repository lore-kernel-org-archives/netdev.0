From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: [PATCH 0/6] bcm63xx_enet: small fixes and cleanups
Date: Sun,  1 Oct 2017 13:02:14 +0200
Message-ID: <20171001110220.27668-1-jonas.gorski@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list@broadcom.com
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.or
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:37402 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750983AbdJALCM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 07:02:12 -0400
Received: by mail-wm0-f67.google.com with SMTP id f4so1870251wmh.4
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 04:02:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes a few theoretical issues and cleans up the code a
bit. It also adds a bit more managed function usage to simplify clock
and iomem usage.

Based on net-next.

Jonas Gorski (6):
  bcm63xx_enet: correct clock usage
  bcm63xx_enet: do not write to random DMA channel on BCM6345
  bcm63xx_enet: do not rely on probe order
  bcm63xx_enet: use managed functions for clock/ioremap
  bcm63xx_enet: drop unneeded NULL phy_clk check
  bcm63xx_enet: remove unneeded include

 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 78 ++++++++++------------------
 drivers/net/ethernet/broadcom/bcm63xx_enet.h |  1 -
 2 files changed, 28 insertions(+), 51 deletions(-)

-- 
2.13.2
