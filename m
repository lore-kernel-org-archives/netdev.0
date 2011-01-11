From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] ah: update maximum truncated ICV length
Date: Tue, 11 Jan 2011 19:06:19 +0100
Message-ID: <4D2C9C1B.1030907@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030506020404000205020600"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53597 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756252Ab1AKSGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 13:06:24 -0500
Received: by wwa36 with SMTP id 36so2066873wwa.1
        for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 10:06:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030506020404000205020600
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

patch is enclosed.


Regards,
Nicolas

--------------030506020404000205020600
Content-Type: text/x-patch;
 name="0001-ah-update-maximum-truncated-ICV-length.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-ah-update-maximum-truncated-ICV-length.patch"

>From 2ca463cf672f000d37a0aaa5e3d3738b50661926 Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 23 Dec 2010 09:52:21 -0500
Subject: [PATCH] ah: update maximum truncated ICV length

For SHA256, RFC4868 requires to truncate ICV length to 128 bits,
hence MAX_AH_AUTH_LEN should be updated to 16.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/ah.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/ah.h b/include/net/ah.h
index f0129f7..be7798d 100644
--- a/include/net/ah.h
+++ b/include/net/ah.h
@@ -4,7 +4,7 @@
 #include <linux/skbuff.h>
 
 /* This is the maximum truncated ICV length that we know of. */
-#define MAX_AH_AUTH_LEN	12
+#define MAX_AH_AUTH_LEN	16
 
 struct crypto_ahash;
 
-- 
1.7.3.4


--------------030506020404000205020600--
