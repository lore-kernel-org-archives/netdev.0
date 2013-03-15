From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 3/5] linux/openvswitch.h: Make OVSP_LOCAL 32-bit.
Date: Fri, 15 Mar 2013 10:38:49 -0700
Message-ID: <1363369131-16830-4-git-send-email-jesse@nicira.com>
References: <1363369131-16830-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:44033 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754284Ab3CORjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 13:39:05 -0400
Received: by mail-oa0-f71.google.com with SMTP id o6so18947092oag.6
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 10:39:04 -0700 (PDT)
In-Reply-To: <1363369131-16830-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno.rajahalme@nsn.com>

OVS ports are now 32-bit, so OVSP_LOCAL should be too.
(Internally, kernel module still keeps port numbers 16-bit, though.)

Signed-off-by: Jarno Rajahalme <jarno.rajahalme@nsn.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/linux/openvswitch.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index d42e174..99e6414 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -94,7 +94,7 @@ struct ovs_vport_stats {
 };
 
 /* Fixed logical ports. */
-#define OVSP_LOCAL      ((__u16)0)
+#define OVSP_LOCAL      ((__u32)0)
 
 /* Packet transfer. */
 
-- 
1.7.10.4
