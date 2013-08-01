From: Sean Cross <xobs@kosagi.com>
Subject: [PATCH v2] Add OF bindings to Micrel PHY
Date: Thu,  1 Aug 2013 06:53:53 +0000
Message-ID: <1375340034-23846-1-git-send-email-xobs@kosagi.com>
Cc: David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sean Cross <xobs@kosagi.com>
To: Duan Fugang-B38611 <B38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.g1.pair.com ([66.39.3.162]:55598 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751040Ab3HAHLL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 03:11:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some boards require custom parameters be passed to the Micrel PHY.
Allow these boards to specify custom timing parameters in the device
tree node.

Changes since v1:
 - removed redefinition of registers and addresses 

Sean Cross (1):
  net/phy: micrel: Add OF configuration support

 .../devicetree/bindings/net/micrel-phy.txt         |   20 ++++++++
 drivers/net/phy/micrel.c                           |   50 ++++++++++++++++++++
 2 files changed, 70 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/micrel-phy.txt

-- 
1.7.9.5
