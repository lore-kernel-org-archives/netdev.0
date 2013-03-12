From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v2 1/5] documentation: dt: bindings: cpsw: cleanup documentation
Date: Tue, 12 Mar 2013 14:46:34 +0530
Message-ID: <1363079798-18147-2-git-send-email-mugunthanvnm@ti.com>
References: <1363079798-18147-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:60519 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932342Ab3CLJRS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 05:17:18 -0400
In-Reply-To: <1363079798-18147-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move all the slave note properties to separate section to reduce the
confusion between slave note properties and cpsw node properties

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index ecfdf75..8e49c42 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -18,13 +18,18 @@ Required properties:
 - cpts_active_slave	: Specifies the slave to use for time stamping
 - cpts_clock_mult	: Numerator to convert input clock ticks into nanoseconds
 - cpts_clock_shift	: Denominator to convert input clock ticks into nanoseconds
-- phy_id		: Specifies slave phy id
-- mac-address		: Specifies slave MAC address
 
 Optional properties:
 - ti,hwmods		: Must be "cpgmac0"
 - no_bd_ram		: Must be 0 or 1
 - dual_emac		: Specifies Switch to act as Dual EMAC
+
+Slave Properties:
+Required properties:
+- phy_id		: Specifies slave phy id
+- mac-address		: Specifies slave MAC address
+
+Optional properties:
 - dual_emac_res_vlan	: Specifies VID to be used to segregate the ports
 
 Note: "ti,hwmods" field is used to fetch the base address and irq
-- 
1.7.9.5
