From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE]: cls_flow: add vlan-tag support
Date: Tue, 05 Feb 2008 15:31:53 +0100
Message-ID: <47A87359.6060900@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080803060809050709090803"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59290 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbYBEOcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 09:32:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080803060809050709090803
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------080803060809050709090803
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 94e9cba778cb97d77d9146dc3bd38ff195bc2c8a
Author: Patrick McHardy <kaber@trash.net>
Date:   Sat Feb 2 18:22:16 2008 +0100

    [IPROUTE]: cls_flow: add vlan-tag support
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 16869c2..e3e9e25 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -348,6 +348,7 @@ enum
 	FLOW_KEY_RTCLASSID,
 	FLOW_KEY_SKUID,
 	FLOW_KEY_SKGID,
+	FLOW_KEY_VLAN_TAG,
 	__FLOW_KEY_MAX,
 };
 
diff --git a/tc/f_flow.c b/tc/f_flow.c
index eca05cd..1537ade 100644
--- a/tc/f_flow.c
+++ b/tc/f_flow.c
@@ -32,7 +32,8 @@ static void explain(void)
 "KEY-LIST := [ KEY-LIST , ] KEY\n"
 "KEY      := [ src | dst | proto | proto-src | proto-dst | iif | priority | \n"
 "              mark | nfct | nfct-src | nfct-dst | nfct-proto-src | \n"
-"              nfct-proto-dst | rt-classid | sk-uid | sk-gid ]\n"
+"              nfct-proto-dst | rt-classid | sk-uid | sk-gid |\n"
+"              vlan-tag ]\n"
 "OPS      := [ or NUM | and NUM | xor NUM | rshift NUM | addend NUM ]\n"
 "ID       := X:Y\n"
 	);
@@ -55,6 +56,7 @@ static const char *flow_keys[FLOW_KEY_MAX+1] = {
 	[FLOW_KEY_RTCLASSID]		= "rt-classid",
 	[FLOW_KEY_SKUID]		= "sk-uid",
 	[FLOW_KEY_SKGID]		= "sk-gid",
+	[FLOW_KEY_VLAN_TAG]		= "vlan-tag",
 };
 
 static int flow_parse_keys(__u32 *keys, __u32 *nkeys, char *argv)

--------------080803060809050709090803--
