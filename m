From: Yan Zheng <yzcorp@gmail.com>
Subject: [PATCH]The type of inet6_ifinfo_notify event  in addrconf_ifdown().
Date: Fri, 14 Oct 2005 18:40:35 +0800
Message-ID: <434F8B23.7090201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750705AbVJNKjb@vger.kernel.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maybe inet6_ifinfo_notify event type should be RTM_DELLINK in 
addrconf_ifdown().

Signed-off-by: Yan Zheng<yanzheng@21cn.com>

Index:  net/ipv6/addrconf.c
------------------------------------------------------------------------
--- linux-2.6.14-rc4-git2/net/ipv6/addrconf.c    2005-10-14 
18:28:01.000000000 +0800
+++ linux/net/ipv6/addrconf.c    2005-10-14 18:31:15.000000000 +0800
@@ -2167,7 +2167,7 @@
 
     /* Step 5: netlink notification of this interface */
     idev->tstamp = jiffies;
-    inet6_ifinfo_notify(RTM_NEWLINK, idev);
+    inet6_ifinfo_notify(RTM_DELLINK, idev);
    
     /* Shot the device (if unregistered) */
 
