From: Yan Zheng <yanzheng@21cn.com>
Subject: [PATCH]A old patch for addrconf_ifdown(...).
Date: Thu, 03 Nov 2005 08:48:55 +0800
Message-ID: <43695E77.3080707@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030232AbVKCArq@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

The patch may be got lost. It's already acked by YOSHIFUJI.


Signed-off-by: Yan Zheng<yanzheng@21cn.com>

Index:  net/ipv6/addrconf.c
------------------------------------------------------------------------
--- linux-2.6.14/net/ipv6/addrconf.c	2005-10-28 08:02:08.000000000 +0800
+++ linux/net/ipv6/addrconf.c	2005-11-03 08:35:11.000000000 +0800
@@ -2167,7 +2167,7 @@ static int addrconf_ifdown(struct net_de
 
 	/* Step 5: netlink notification of this interface */
 	idev->tstamp = jiffies;
-	inet6_ifinfo_notify(RTM_NEWLINK, idev);
+	inet6_ifinfo_notify(RTM_DELLINK, idev);
 	
 	/* Shot the device (if unregistered) */
 
