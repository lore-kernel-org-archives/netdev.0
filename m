From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/2] e1000e: fix error checks
Date: Mon, 15 Oct 2007 14:02:21 -0700
Message-ID: <20071015210221.26666.14629.stgit@localhost.localdomain>
References: <20071015210213.26666.90484.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@kernel.org, joe@perches.com,
	auke-jan.h.kok@intel.com
To: jeff@garzik.ok
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42459 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757468AbXJOVCs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 17:02:48 -0400
In-Reply-To: <20071015210213.26666.90484.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>

Spotted by the Coverity checker.

Signed-off-by: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/ethtool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index b7a7e2a..ca06c35 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1451,11 +1451,11 @@ static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 	}
 
 	*data = e1000_setup_desc_rings(adapter);
-	if (data)
+	if (*data)
 		goto out;
 
 	*data = e1000_setup_loopback_test(adapter);
-	if (data)
+	if (*data)
 		goto err_loopback;
 
 	*data = e1000_run_loopback_test(adapter);
