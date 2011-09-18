From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH 0/4] add fec support for imx6q
Date: Sun, 18 Sep 2011 19:54:08 +0800
Message-ID: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, patches@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:48130 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573Ab1IRLwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 07:52:13 -0400
Received: by pzk1 with SMTP id 1so7732480pzk.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2011 04:52:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds imx6q enet support.  The imx6q enet is a derivative of
imx28 enet controller.  It fixed the frame endian issue found on imx28,
and added 1 Gbps support.

It's based on v3.1-rc6.

Shawn Guo (4):
      net/fec: change phy-reset-gpio request warning to debug message
      net/fec: fix fec1 check in fec_enet_mii_init()
      net/fec: set phy_speed to the optimal frequency 2.5 MHz
      net/fec: add imx6q enet support

 drivers/net/Kconfig |    3 +-
 drivers/net/fec.c   |   65 ++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 52 insertions(+), 16 deletions(-)
