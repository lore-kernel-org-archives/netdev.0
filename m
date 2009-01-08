From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax: fix kernel-doc for debufs_dentry member of struct wimax_dev
Date: Thu,  8 Jan 2009 12:50:27 -0800
Message-ID: <1231447827-7999-1-git-send-email-inaky@linux.intel.com>
Cc: Inaky Perez-Gonzalez <inaky@linux.intel.com>,
	Randy Dunlapy <randy.dunlap@intel.com>
To: wimax@linuxwimax.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:14228 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750833AbZAHUu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 15:50:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported by Randy Dunlap from a warning in the v2.6.29 merge window
tree as of 2009/1/8.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Cc: Randy Dunlapy <randy.dunlap@intel.com>
---
 include/net/wimax.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/net/wimax.h b/include/net/wimax.h
index 1602614..073809c 100644
--- a/include/net/wimax.h
+++ b/include/net/wimax.h
@@ -323,6 +323,9 @@ struct input_dev;
  *
  * @rf_hw: [private] State of the hardware radio switch (OFF/ON)
  *
+ * @debufs_dentry: [private] Used to hook up a debugfs entry. This
+ *     shows up in the debugfs root as wimax:DEVICENAME.
+ *
  * Description:
  * This structure defines a common interface to access all WiMAX
  * devices from different vendors and provides a common API as well as
-- 
1.5.6.5

