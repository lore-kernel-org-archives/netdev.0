From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipconfig: make two variables static
Date: Mon, 21 Apr 2014 19:55:43 +0800
Message-ID: <1398081344-32079-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:42715 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbaDULzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 07:55:47 -0400
Received: by mail-pd0-f176.google.com with SMTP id r10so3613814pdi.35
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 04:55:46 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id tf10sm77620476pbc.70.2014.04.21.04.55.44
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 21 Apr 2014 04:55:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

make two variables static to kill the warning:
 warning: symbol 'ic_addrservaddr' was not declared. Should it be static?
 warning: symbol 'ic_dev_xid' was not declared. Should it be static?

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/ipconfig.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index b3e86ea..2d599fa 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -136,14 +136,15 @@ __be32 ic_myaddr = NONE;		/* My IP address */
 static __be32 ic_netmask = NONE;	/* Netmask for local subnet */
 __be32 ic_gateway = NONE;	/* Gateway IP address */
 
-__be32 ic_addrservaddr = NONE;	/* IP Address of the IP addresses'server */
-
+/* IP Address of the IP addresses'server */
+static __be32 ic_addrservaddr = NONE;
+
 __be32 ic_servaddr = NONE;	/* Boot server IP address */
 
 __be32 root_server_addr = NONE;	/* Address of NFS server */
 u8 root_server_path[256] = { 0, };	/* Path to mount as root */
 
-__be32 ic_dev_xid;		/* Device under configuration */
+static __be32 ic_dev_xid;		/* Device under configuration */
 
 /* vendor class identifier */
 static char vendor_class_identifier[253] __initdata;
-- 
1.7.10.4
