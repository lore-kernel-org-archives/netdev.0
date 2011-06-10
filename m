From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 10/12] igb: Change version to remove number after -k in kernel versions.
Date: Thu,  9 Jun 2011 20:47:54 -0700
Message-ID: <1307677676-26690-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307677676-26690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56870 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754718Ab1FJDsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 23:48:05 -0400
In-Reply-To: <1307677676-26690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch changes the way versioning is done for igb in the kernel by
removing the number after the "k."  It has been determined that just the
"k" is sufficient to identify a kernel version and the following number
was used in an inconsistent manner.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/igb_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 18fccf9..c2e9670 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -54,9 +54,8 @@
 #define MAJ 3
 #define MIN 0
 #define BUILD 6
-#define KFIX 2
 #define DRV_VERSION __stringify(MAJ) "." __stringify(MIN) "." \
-__stringify(BUILD) "-k" __stringify(KFIX)
+__stringify(BUILD) "-k"
 char igb_driver_name[] = "igb";
 char igb_driver_version[] = DRV_VERSION;
 static const char igb_driver_string[] =
-- 
1.7.5.2

