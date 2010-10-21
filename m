From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 06/12] ipconfig: make local variables/function static
Date: Thu, 21 Oct 2010 10:50:51 -0700
Message-ID: <20101021175148.504406585@vyatta.com>
References: <20101021175045.625707607@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36297 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756147Ab0JUSBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 14:01:04 -0400
Content-Disposition: inline; filename=ipconfig-local.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/ipconfig.c	2010-10-19 10:29:06.307382554 -0700
+++ b/net/ipv4/ipconfig.c	2010-10-19 10:32:05.564463819 -0700
@@ -112,12 +112,12 @@
  * variables using firmware environment vars.  If this is set, it will
  * ignore such firmware variables.
  */
-int ic_set_manually __initdata = 0;		/* IPconfig parameters set manually */
+static int ic_set_manually __initdata = 0; /* IPconfig parameters set manually */
 
 static int ic_enable __initdata = 0;		/* IP config enabled? */
 
 /* Protocol choice */
-int ic_proto_enabled __initdata = 0
+static int ic_proto_enabled __initdata = 0
 #ifdef IPCONFIG_BOOTP
 			| IC_BOOTP
 #endif
@@ -131,16 +131,16 @@ int ic_proto_enabled __initdata = 0
 
 static int ic_host_name_set __initdata = 0;	/* Host name set by us? */
 
-__be32 ic_myaddr = NONE;		/* My IP address */
+static __be32 ic_myaddr = NONE;		/* My IP address */
 static __be32 ic_netmask = NONE;	/* Netmask for local subnet */
-__be32 ic_gateway = NONE;	/* Gateway IP address */
+static __be32 ic_gateway = NONE;	/* Gateway IP address */
 
-__be32 ic_servaddr = NONE;	/* Boot server IP address */
+static __be32 ic_servaddr = NONE;	/* Boot server IP address */
 
-__be32 root_server_addr = NONE;	/* Address of NFS server */
-u8 root_server_path[256] = { 0, };	/* Path to mount as root */
+static __be32 root_server_addr = NONE;	/* Address of NFS server */
+static u8 root_server_path[256] = { 0 }; /* Path to mount as root */
 
-u32 ic_dev_xid;		/* Device under configuration */
+static u32 ic_dev_xid;		/* Device under configuration */
 
 /* vendor class identifier */
 static char vendor_class_identifier[253] __initdata;
@@ -1289,7 +1289,7 @@ static const struct file_operations pnp_
  *  need to have root_server_addr set _before_ IPConfig gets called as it
  *  can override it.
  */
-__be32 __init root_nfs_parse_addr(char *name)
+static __be32 __init root_nfs_parse_addr(char *name)
 {
 	__be32 addr;
 	int octets = 0;


