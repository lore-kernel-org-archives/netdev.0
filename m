From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v3 2/3] rtnetlink: new filter RTEXT_FILTER_BRVLAN_COMPRESSED
Date: Sat, 10 Jan 2015 07:31:13 -0800
Message-ID: <1420903874-25528-3-git-send-email-roopa@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:55936 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103AbbAJPbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 10:31:24 -0500
Received: by mail-yk0-f176.google.com with SMTP id 79so6266654ykr.7
        for <netdev@vger.kernel.org>; Sat, 10 Jan 2015 07:31:23 -0800 (PST)
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
