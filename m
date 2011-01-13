From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] ipsec: update MAX_AH_AUTH_LEN to support sha512
Date: Thu, 13 Jan 2011 22:51:03 +0100
Message-ID: <4D2F73C7.8010107@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020200010607080509020103"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40757 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab1AMVvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 16:51:08 -0500
Received: by wwa36 with SMTP id 36so2307442wwa.1
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 13:51:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020200010607080509020103
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

here is a second patch after "ah: update maximum truncated ICV length". Sorry 
for not being more watchful the first time.
512 is the maximum I found in net/xfrm/xfrm_algo.c


Regards,
Nicolas

--------------020200010607080509020103
Content-Type: text/x-patch;
 name="0001-ipsec-update-MAX_AH_AUTH_LEN-to-support-sha512.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-ipsec-update-MAX_AH_AUTH_LEN-to-support-sha512.patch"

>From e330817aa2b33e9d1f44071072fdc4778acf8d76 Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 13 Jan 2011 14:20:19 -0500
Subject: [PATCH] ipsec: update MAX_AH_AUTH_LEN to support sha512

icv_truncbits is set to 256 for sha512, so update
MAX_AH_AUTH_LEN to 64.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/ah.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/ah.h b/include/net/ah.h
index be7798d..ca95b98 100644
--- a/include/net/ah.h
+++ b/include/net/ah.h
@@ -4,7 +4,7 @@
 #include <linux/skbuff.h>
 
 /* This is the maximum truncated ICV length that we know of. */
-#define MAX_AH_AUTH_LEN	16
+#define MAX_AH_AUTH_LEN	64
 
 struct crypto_ahash;
 
-- 
1.5.6.5


--------------020200010607080509020103--
