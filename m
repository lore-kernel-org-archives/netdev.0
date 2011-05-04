From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 1/9] e100: fix build warning
Date: Wed,  4 May 2011 12:30:33 -0700
Message-ID: <1304537441-2056-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65291 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755392Ab1EDTap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 15:30:45 -0400
In-Reply-To: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

In function 'e100_hw_init':
warning: 'err' may be used uninitialized in this function

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by:  Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e100.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index c810cda..29f812d 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1512,7 +1512,7 @@ static int e100_phy_init(struct nic *nic)
 
 static int e100_hw_init(struct nic *nic)
 {
-	int err;
+	int err = 0;
 
 	e100_hw_reset(nic);
 
-- 
1.7.4.4

