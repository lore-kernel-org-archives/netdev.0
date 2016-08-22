From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v05 62/72] include/uapi/linux/openvswitch.h: use __u32 from linux/types.h
Date: Mon, 22 Aug 2016 20:33:19 +0200
Message-ID: <1471890809-4383-63-git-send-email-mikko.rapeli@iki.fi>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>,
        Pravin Shelar <pshelar@nicira.com>, netdev@vger.kernel.org,
        dev@openvswitch.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kernel uapi header are supposed to use them. Fixes userspace compile error:

linux/openvswitch.h:583:2: error: unknown type name ‘uint32_t’

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/openvswitch.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 645499a..54c3b4f 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -583,7 +583,7 @@ enum ovs_userspace_attr {
 #define OVS_USERSPACE_ATTR_MAX (__OVS_USERSPACE_ATTR_MAX - 1)
 
 struct ovs_action_trunc {
-	uint32_t max_len; /* Max packet size in bytes. */
+	__u32 max_len; /* Max packet size in bytes. */
 };
 
 /**
-- 
2.8.1
