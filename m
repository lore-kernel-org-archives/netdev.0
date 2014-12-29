From: roopa@cumulusnetworks.com
Subject: [PATCH 4/6] rtnetlink: new filter RTEXT_FILTER_BRVLAN_COMPRESSED
Date: Mon, 29 Dec 2014 13:05:30 -0800
Message-ID: <1419887132-7084-5-git-send-email-roopa@cumulusnetworks.com>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
To: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:58614 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbaL2VFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 16:05:44 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so18347007pab.0
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 13:05:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This filter is same as RTEXT_FILTER_BRVLAN except that it tries
to compress the consecutive vlans into ranges.

This helps on systems with large number of configured vlans.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/uapi/linux/rtnetlink.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 9c9b8b4..d5a5316 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -634,6 +634,7 @@ struct tcamsg {
 /* New extended info filters for IFLA_EXT_MASK */
 #define RTEXT_FILTER_VF		(1 << 0)
 #define RTEXT_FILTER_BRVLAN	(1 << 1)
+#define RTEXT_FILTER_BRVLAN_COMPRESSED	(1 << 2)
 
 /* End of information exported to user level */
 
-- 
1.7.10.4
