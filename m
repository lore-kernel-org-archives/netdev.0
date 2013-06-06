From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 0/2] Adding pinctrl PM support for CPSW and Davinci MDIO
Date: Thu, 6 Jun 2013 23:45:13 +0530
Message-ID: <1370542515-22009-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linus.walleij@linaro.org>,
	<broonie@kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:38262 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313Ab3FFSOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 14:14:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Adding pinctrl PM support for CPSW and MDIO for Power Optimization
* Adopted to the new pinctrl core PM helpers added by Linus Walleij in 
  http://marc.info/?l=linux-arm-kernel&m=137044113914184&w=2. This change
  was suggested by Mark Brown in my another patch series posted for CPSW
  and MDIO pinctrl.

David Miller:
  As this patch is based on the patch from Linus Walleij's patch
  "drivers: pinctrl sleep and idle states in the core", can you ACK this
  patch series so that Linus Walleij can take this patch via pinctrl tree.

Mugunthan V N (2):
  drivers: net: cpsw: use pinctrl PM helpers
  drivers: net: davinci_mdio: use pinctrl PM helpers

 drivers/net/ethernet/ti/cpsw.c         |   11 +++++++++++
 drivers/net/ethernet/ti/davinci_mdio.c |   10 ++++++++++
 2 files changed, 21 insertions(+)

-- 
1.7.9.5
