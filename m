From: sfeldma@gmail.com
Subject: [PATCH net-next RFC 1/5] neighbour: add external aged flag
Date: Thu, 19 Feb 2015 23:09:51 -0800
Message-ID: <1424416195-19098-2-git-send-email-sfeldma@gmail.com>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, gospo@cumulusnetworks.com,
	vbandaru@broadcom.com, siva.mannem.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:41917 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbbBTHJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 02:09:28 -0500
Received: by pdno5 with SMTP id o5so5694952pdn.8
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 23:09:28 -0800 (PST)
In-Reply-To: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

NFT_EXT_AGED marks neighbor (FDB) entries as externally aged, typically in
hardware.  Software can skip these entries when aging entries.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/uapi/linux/neighbour.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index 3873a35..e9866f9 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -40,6 +40,7 @@ enum {
 #define NTF_MASTER	0x04
 #define NTF_PROXY	0x08	/* == ATF_PUBL */
 #define NTF_EXT_LEARNED	0x10
+#define NTF_EXT_AGED	0x20
 #define NTF_ROUTER	0x80
 
 /*
-- 
1.7.10.4
