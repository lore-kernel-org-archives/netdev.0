From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 2/7] openvswitch: Fix typos in CT headers
Date: Tue, 29 Sep 2015 15:39:35 -0700
Message-ID: <1443566380-22640-3-git-send-email-joestringer@nicira.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These comments hadn't caught up to their implementations, fix them.

Fixes: 7f8a436 "openvswitch: Add conntrack action"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 include/uapi/linux/openvswitch.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 9afcd60..7cbb9d5 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -630,7 +630,7 @@ struct ovs_action_hash {
  */
 enum ovs_ct_attr {
 	OVS_CT_ATTR_UNSPEC,
-	OVS_CT_ATTR_FLAGS,      /* u8 bitmask of OVS_CT_F_*. */
+	OVS_CT_ATTR_FLAGS,      /* u32 bitmask of OVS_CT_F_*. */
 	OVS_CT_ATTR_ZONE,       /* u16 zone id. */
 	OVS_CT_ATTR_MARK,       /* mark to associate with this connection. */
 	OVS_CT_ATTR_LABELS,     /* labels to associate with this connection. */
@@ -705,7 +705,7 @@ enum ovs_action_attr {
 				       * data immediately followed by a mask.
 				       * The data must be zero for the unmasked
 				       * bits. */
-	OVS_ACTION_ATTR_CT,           /* One nested OVS_CT_ATTR_* . */
+	OVS_ACTION_ATTR_CT,           /* Nested OVS_CT_ATTR_* . */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
-- 
2.1.4
