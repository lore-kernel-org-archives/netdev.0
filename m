From: David Ahern <dsahern@gmail.com>
Subject: [PATCH 1/2] e1000e: Add pm_qos header
Date: Tue, 12 May 2015 09:36:59 -0600
Message-ID: <1431445020-25235-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>, Thomas Graf <tgraf@suug.ch>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:35278 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbbELPhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:37:18 -0400
Received: by iebpz10 with SMTP id pz10so4722759ieb.2
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:37:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e2c6544829f moved pm_qos_req to e1000_adapter. Add the header file
that defines the struct.

Signed-off-by: David Ahern <dsahern@gmail.com>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 5d9ceb17b4cb..0abc942c966e 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -40,6 +40,7 @@
 #include <linux/ptp_classify.h>
 #include <linux/mii.h>
 #include <linux/mdio.h>
+#include <linux/pm_qos.h>
 #include "hw.h"
 
 struct e1000_info;
-- 
2.2.1
