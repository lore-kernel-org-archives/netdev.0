From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH 6/7] be2net: change the driver description
Date: Tue, 9 Feb 2010 17:08:06 +0530
Message-ID: <20100209113755.GA10577@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f182.google.com ([209.85.223.182]:48810 "EHLO
	mail-iw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153Ab0BILiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 06:38:13 -0500
Received: by iwn12 with SMTP id 12so8480142iwn.26
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2010 03:38:11 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the driver is supporting multiple generations of the ASIC
remove ASIC generation information from the driver description.
This information is displayed by modinfo.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 476a5c4..b39b385 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -38,7 +38,7 @@
 #define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
 #define OC_NAME			"Emulex OneConnect 10Gbps NIC"
 #define OC_NAME1		"Emulex OneConnect 10Gbps NIC (be3)"
-#define DRV_DESC		BE_NAME "Driver"
+#define DRV_DESC		"ServerEngines BladeEngine 10Gbps NIC Driver"
 
 #define BE_VENDOR_ID 		0x19a2
 #define BE_DEVICE_ID1		0x211
-- 
1.6.3.3

