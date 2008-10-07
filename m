From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE]: Support "ip link add help" for rtnl_link API
Date: Tue, 07 Oct 2008 17:16:08 +0200
Message-ID: <48EB7D38.1030503@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010002000707080509040105"
To: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48918 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbYJGPQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 11:16:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010002000707080509040105
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------010002000707080509040105
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 91cb1e34144e62c0a9e767d1a766c1827d79f770
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Oct 7 16:47:03 2008 +0200

    [IPROUTE]: Support "ip link add help" for rtnl_link API
    
    For some reason "ip link add help" is currently not supported when using
    the new rtnl_link API. Fix that.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/ip/iplink.c b/ip/iplink.c
index f4cbeb3..81122ae 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -274,6 +274,8 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
 			}
+			if (matches(*argv, "help") == 0)
+				usage();
 			if (*dev)
 				duparg2("dev", *argv);
 			*dev = *argv;

--------------010002000707080509040105--
