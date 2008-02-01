From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/6] e1000: make e1000_dump_eeprom() static
Date: Fri, 01 Feb 2008 08:21:28 -0800
Message-ID: <20080201162128.29347.56899.stgit@localhost.localdomain>
References: <20080201162118.29347.13268.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31082 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755013AbYBAQV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 11:21:29 -0500
In-Reply-To: <20080201162118.29347.13268.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>

This patch makes the needlessly global e1000_dump_eeprom() static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8c87940..7c5b05a 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -853,7 +853,7 @@ e1000_reset(struct e1000_adapter *adapter)
 /**
  *  Dump the eeprom for users having checksum issues
  **/
-void e1000_dump_eeprom(struct e1000_adapter *adapter)
+static void e1000_dump_eeprom(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct ethtool_eeprom eeprom;

