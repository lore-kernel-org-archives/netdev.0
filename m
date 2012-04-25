From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 7/8] isdn/capi: fix readability damage
Date: Thu, 26 Apr 2012 01:02:20 +0200 (CEST)
Message-ID: <20120425-patch-gigaset-07.tilman@imap.cc>
References: <20120425-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:35428 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932516Ab2DYXDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 19:03:32 -0400
In-Reply-To: <20120425-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix up some of the readibility deterioration caused by the recent
whitespace coding style cleanup.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capi.c    |   23 +++++++----------------
 drivers/isdn/capi/capidrv.c |    8 +++++---
 2 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index b902794..9ee3991 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -786,7 +786,6 @@ register_out:
 		return retval;
 
 	case CAPI_GET_VERSION:
-	{
 		if (copy_from_user(&data.contr, argp,
 				   sizeof(data.contr)))
 			return -EFAULT;
@@ -796,11 +795,9 @@ register_out:
 		if (copy_to_user(argp, &data.version,
 				 sizeof(data.version)))
 			return -EFAULT;
-	}
-	return 0;
+		return 0;
 
 	case CAPI_GET_SERIAL:
-	{
 		if (copy_from_user(&data.contr, argp,
 				   sizeof(data.contr)))
 			return -EFAULT;
@@ -810,10 +807,9 @@ register_out:
 		if (copy_to_user(argp, data.serial,
 				 sizeof(data.serial)))
 			return -EFAULT;
-	}
-	return 0;
+		return 0;
+
 	case CAPI_GET_PROFILE:
-	{
 		if (copy_from_user(&data.contr, argp,
 				   sizeof(data.contr)))
 			return -EFAULT;
@@ -837,11 +833,9 @@ register_out:
 		}
 		if (retval)
 			return -EFAULT;
-	}
-	return 0;
+		return 0;
 
 	case CAPI_GET_MANUFACTURER:
-	{
 		if (copy_from_user(&data.contr, argp,
 				   sizeof(data.contr)))
 			return -EFAULT;
@@ -853,8 +847,8 @@ register_out:
 				 sizeof(data.manufacturer)))
 			return -EFAULT;
 
-	}
-	return 0;
+		return 0;
+
 	case CAPI_GET_ERRCODE:
 		data.errcode = cdev->errcode;
 		cdev->errcode = CAPI_NOERROR;
@@ -870,8 +864,7 @@ register_out:
 			return 0;
 		return -ENXIO;
 
-	case CAPI_MANUFACTURER_CMD:
-	{
+	case CAPI_MANUFACTURER_CMD: {
 		struct capi_manufacturer_cmd mcmd;
 		if (!capable(CAP_SYS_ADMIN))
 			return -EPERM;
@@ -879,8 +872,6 @@ register_out:
 			return -EFAULT;
 		return capi20_manufacturer(mcmd.cmd, mcmd.data);
 	}
-	return 0;
-
 	case CAPI_SET_FLAGS:
 	case CAPI_CLR_FLAGS: {
 		unsigned userflags;
diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index 6f5016b..832bc80 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -1593,7 +1593,7 @@ static int capidrv_command(isdn_ctrl *c, capidrv_contr *card)
 		return capidrv_ioctl(c, card);
 
 	switch (c->command) {
-	case ISDN_CMD_DIAL:{
+	case ISDN_CMD_DIAL: {
 		u8 calling[ISDN_MSNLEN + 3];
 		u8 called[ISDN_MSNLEN + 2];
 
@@ -2072,7 +2072,8 @@ static int capidrv_addcontr(u16 contr, struct capi_profile *profp)
 	card->interface.writebuf_skb = if_sendbuf;
 	card->interface.writecmd = NULL;
 	card->interface.readstat = if_readstat;
-	card->interface.features = ISDN_FEATURE_L2_HDLC |
+	card->interface.features =
+		ISDN_FEATURE_L2_HDLC |
 		ISDN_FEATURE_L2_TRANS |
 		ISDN_FEATURE_L3_TRANS |
 		ISDN_FEATURE_P_UNKNOWN |
@@ -2080,7 +2081,8 @@ static int capidrv_addcontr(u16 contr, struct capi_profile *profp)
 		ISDN_FEATURE_L2_X75UI |
 		ISDN_FEATURE_L2_X75BUI;
 	if (profp->support1 & (1 << 2))
-		card->interface.features |= ISDN_FEATURE_L2_V11096 |
+		card->interface.features |=
+			ISDN_FEATURE_L2_V11096 |
 			ISDN_FEATURE_L2_V11019 |
 			ISDN_FEATURE_L2_V11038;
 	if (profp->support1 & (1 << 8))
-- 
1.7.3.4
