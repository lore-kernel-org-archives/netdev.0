From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax: fix kernel-doc for debufs_dentry member of struct wimax_dev [v2]
Date: Thu,  8 Jan 2009 12:59:56 -0800
Message-ID: <1231448396-8582-1-git-send-email-inaky@linux.intel.com>
References: <1231447827-7999-1-git-send-email-inaky@linux.intel.com>
Cc: Inaky Perez-Gonzalez <inaky@linux.intel.com>,
	Randy Dunlap <randy.dunlap@oracle.com>
To: wimax@linuxwimax.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:34869 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756643AbZAHU75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 15:59:57 -0500
In-Reply-To: <1231447827-7999-1-git-send-email-inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported by Randy Dunlap from a warning in the v2.6.29 merge window
tree as of 2009/1/8.

v2 fixes Randy Dunlap's email address.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>
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

