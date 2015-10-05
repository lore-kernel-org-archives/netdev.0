From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net 1/6] openvswitch: Fix typos in CT headers
Date: Mon,  5 Oct 2015 15:23:14 -0700
Message-ID: <1444083799-57090-2-git-send-email-joestringer@nicira.com>
References: <1444083799-57090-1-git-send-email-joestringer@nicira.com>
Cc: davem@davemloft.net, pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36240 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbbJEWX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 18:23:27 -0400
Received: by pablk4 with SMTP id lk4so187785535pab.3
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 15:23:27 -0700 (PDT)
In-Reply-To: <1444083799-57090-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These comments hadn't caught up to their implementations, fix them.

Fixes: 7f8a436 "openvswitch: Add conntrack action"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
v3: No change.
v2: Acked.
---
 include/uapi/linux/openvswitch.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index c736344afed4..a9a4a59912e9 100644
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
