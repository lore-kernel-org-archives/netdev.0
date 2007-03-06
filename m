From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/3] e1000: Use ARRAY_SIZE macro when appropriate
Date: Tue, 06 Mar 2007 08:58:02 -0800
Message-ID: <20070306165802.27452.22955.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com,
	jesse.brandeburg@intel.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41697 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965959AbXCFQ61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 11:58:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <darwish.07@gmail.com>

A patch to use ARRAY_SIZE macro already defined in kernel.h.

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 6777887..a094288 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -742,7 +742,7 @@ err_setup:
 	uint32_t pat, value;                                                   \
 	uint32_t test[] =                                                      \
 		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};              \
-	for (pat = 0; pat < sizeof(test)/sizeof(test[0]); pat++) {              \
+	for (pat = 0; pat < ARRAY_SIZE(test); pat++) {              \
 		E1000_WRITE_REG(&adapter->hw, R, (test[pat] & W));             \
 		value = E1000_READ_REG(&adapter->hw, R);                       \
 		if (value != (test[pat] & W & M)) {                             \
