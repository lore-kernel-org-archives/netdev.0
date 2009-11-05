From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH] netdev: Fix compile error in Octeon MGMT driver.
Date: Thu,  5 Nov 2009 11:38:32 -0800
Message-ID: <1257449912-27978-1-git-send-email-ddaney@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:8082 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758778AbZKETk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 14:40:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Explicitly include linux/capability.h.  Under some configurations it
wasn't being indirectly included.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
This fixes a minor problem for the (already approved) patches that
Ralf has queued for 2.6.33.  It should probably be added to Ralf's
queue.

 drivers/net/octeon/octeon_mgmt.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index 83a636d..050538b 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -6,6 +6,7 @@
  * Copyright (C) 2009 Cavium Networks
  */
 
+#include <linux/capability.h>
 #include <linux/dma-mapping.h>
 #include <linux/init.h>
 #include <linux/platform_device.h>
-- 
1.6.0.6

