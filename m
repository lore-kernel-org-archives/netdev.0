From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/6] e1000e: make a function static
Date: Fri, 01 Feb 2008 08:21:18 -0800
Message-ID: <20080201162118.29347.13268.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7770 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754468AbYBAQZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 11:25:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>

This patch makes the needlessly global reg_pattern_test_array() static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/ethtool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 6d9c27f..a2034cf 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -690,8 +690,8 @@ err_setup:
 	return err;
 }
 
-bool reg_pattern_test_array(struct e1000_adapter *adapter, u64 *data,
-			    int reg, int offset, u32 mask, u32 write)
+static bool reg_pattern_test_array(struct e1000_adapter *adapter, u64 *data,
+				   int reg, int offset, u32 mask, u32 write)
 {
 	int i;
 	u32 read;

