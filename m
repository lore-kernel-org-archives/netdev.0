From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch netdev-2.4] vlan_dev: return 0 on vlan_dev_change_mtu success
Date: Thu, 18 Nov 2004 14:27:49 -0500
Message-ID: <20041118142749.C16007@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
        netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The VLAN net driver needs to return 0 from vlan_dev_change_mtu()
on success.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
The proper sucessful return code for the change_mtu() method is zero.
For some reason, vlan_dev_change_mtu() is returning the new mtu value
instead.

 net/8021q/vlan_dev.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- 1.14/net/8021q/vlan_dev.c	2004-07-05 19:34:03 -04:00
+++ edited/net/8021q/vlan_dev.c	2004-11-18 14:26:29 -05:00
@@ -528,7 +528,7 @@
 
 	dev->mtu = new_mtu;
 
-	return new_mtu;
+	return 0;
 }
 
 int vlan_dev_set_ingress_priority(char *dev_name, __u32 skb_prio, short vlan_prio)
