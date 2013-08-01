From: Sean Cross <xobs@kosagi.com>
Subject: [PATCH] Add OF bindings to Micrel PHY
Date: Thu,  1 Aug 2013 04:16:40 +0000
Message-ID: <1375330601-3609-1-git-send-email-xobs@kosagi.com>
Cc: Sean Cross <xobs@kosagi.com>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.g1.pair.com ([66.39.3.162]:34398 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751059Ab3HAEka (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 00:40:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some boards require custom parameters be passed to the Micrel PHY.
Allow these boards to specify custom timing parameters in the device
tree node.

Sean Cross (1):
  net/phy: micrel: Add OF configuration support

 .../devicetree/bindings/net/micrel-phy.txt         |   20 +++++++
 drivers/net/phy/micrel.c                           |   57 ++++++++++++++++++++
 2 files changed, 77 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/micrel-phy.txt

-- 
1.7.9.5
