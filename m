From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2 1/4] if_link.h: rebase to the kernel
Date: Thu,  7 Apr 2016 14:36:26 +0200
Message-ID: <7d6dd5a6d63ed662caabac797809ec9028a76cf7.1460032274.git.jbenc@redhat.com>
References: <cover.1460032274.git.jbenc@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47483 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755633AbcDGMhV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 08:37:21 -0400
In-Reply-To: <cover.1460032274.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not intended to be applied directly. Instead, I assume Stephen will rebase
all headers to net-next as usual.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/linux/if_link.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 9b7f3c8d64c4..7e6fe6798a41 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -484,6 +484,7 @@ enum {
 	IFLA_VXLAN_REMCSUM_NOPARTIAL,
 	IFLA_VXLAN_COLLECT_METADATA,
 	IFLA_VXLAN_LABEL,
+	IFLA_VXLAN_GPE,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
-- 
1.8.3.1
