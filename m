From: Sean Cross <xobs@kosagi.com>
Subject: [PATCH v3] Add OF bindings to Micrel ksz9021 PHY
Date: Thu,  1 Aug 2013 09:19:16 +0000
Message-ID: <1375348757-12856-1-git-send-email-xobs@kosagi.com>
Cc: David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sean Cross <xobs@kosagi.com>
To: Sascha Hauer <s.hauer@pengutronix.de>,
	Duan Fugang-B38611 <B38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.g1.pair.com ([66.39.3.162]:28799 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204Ab3HAJgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 05:36:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some boards require custom parameters be passed to the Micrel PHY.
Allow these boards to specify custom timing parameters in the device
tree node.

Changes since v2:
 - limited the scope to just ksz9021 rather than all PHYs

Changes since v1:
 - removed redefinition of registers and addresses 

Sean Cross (1):
  net/phy: micrel: Add OF configuration support for ksz9021

 .../devicetree/bindings/net/micrel-ksz9021.txt     |   19 +++++++
 drivers/net/phy/micrel.c                           |   57 +++++++++++++++++++-
 2 files changed, 75 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/micrel-ksz9021.txt

-- 
1.7.9.5
