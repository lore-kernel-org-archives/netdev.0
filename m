From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 2/7] openvswitch: Fix typos in CT headers
Date: Thu,  1 Oct 2015 13:53:25 -0700
Message-ID: <1443732810-38746-3-git-send-email-joestringer@nicira.com>
References: <1443732810-38746-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, jesse@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36833 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757081AbbJAUxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 16:53:38 -0400
Received: by pablk4 with SMTP id lk4so84254651pab.3
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 13:53:38 -0700 (PDT)
In-Reply-To: <1443732810-38746-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These comments hadn't caught up to their implementations, fix them.

Fixes: 7f8a436 "openvswitch: Add conntrack action"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
v2: Acked.
---
 include/uapi/linux/openvswitch.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index c736344..a9a4a59 100644
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
