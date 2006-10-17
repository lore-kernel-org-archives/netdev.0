From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/8] e1000: FIX: 82542 doesn't support WoL
Date: Tue, 17 Oct 2006 12:02:37 -0700
Message-ID: <20061017190237.4194.94743.stgit@gitlost.site>
References: <20061017190139.4194.20128.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:15630 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751431AbWJQSxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 14:53:50 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061017190139.4194.20128.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Exclude 82542 when setting up WoL. This card does not do WoL at all.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 71fb278..c564adb 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1691,6 +1691,7 @@ static int e1000_wol_exclusion(struct e1
 	int retval = 1; /* fail by default */
 
 	switch (hw->device_id) {
+	case E1000_DEV_ID_82542:
 	case E1000_DEV_ID_82543GC_FIBER:
 	case E1000_DEV_ID_82543GC_COPPER:
 	case E1000_DEV_ID_82544EI_FIBER:



---
Auke Kok <auke-jan.h.kok@intel.com>
