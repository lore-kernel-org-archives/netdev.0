From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/3] forcedeth: le32 annotation
Date: Thu, 27 Jul 2006 18:50:09 -0700
Message-ID: <20060728015054.393160616@localhost>
References: <20060728015007.625581647@localhost>
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39094 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932102AbWG1B43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 21:56:29 -0400
To: Ayaz Abdulla <aabdulla@nvidia.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=forcedeth-types.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use __le32 to indicate byte order of hardware ring elements

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

 drivers/net/forcedeth.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- linux-2.6.orig/drivers/net/forcedeth.c	2006-07-27 17:43:52.000000000 -0700
+++ linux-2.6/drivers/net/forcedeth.c	2006-07-27 17:44:49.000000000 -0700
@@ -381,15 +381,15 @@
 
 /* Big endian: should work, but is untested */
 struct ring_desc {
-	u32 buf;
-	u32 flaglen;
+	__le32 buf;
+	__le32 flaglen;
 };
 
 struct ring_desc_ex {
-	u32 bufhigh;
-	u32 buflow;
-	u32 txvlan;
-	u32 flaglen;
+	__le32 bufhigh;
+	__le32 buflow;
+	__le32 txvlan;
+	__le32 flaglen;
 };
 
 union ring_type {
@@ -653,8 +653,8 @@
 };
 
 struct register_test {
-	u32 reg;
-	u32 mask;
+	__le32 reg;
+	__le32 mask;
 };
 
 static const struct register_test nv_registers_test[] = {

--

