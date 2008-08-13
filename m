From: "Park Ji-In" <tisphie@gmail.com>
Subject: [PATCH] rearrange structure xfrm_userpolicy_type in linux/xfrm.h
Date: Wed, 13 Aug 2008 16:56:32 +0900
Message-ID: <c4ee36230808130056s7d01ebaeh677593ef7c099985@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:30315 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbYHMH4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 03:56:33 -0400
Received: by yx-out-2324.google.com with SMTP id 8so1134355yxm.1
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 00:56:32 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct xfrm_userpolicy_type in linux/xfrm.h is something strange,
It seems that to align 4byte, but it's size in x86 with gcc is 6byte.
rearrange to fit in 4byte structure

Signed-off-by: Park Jiin <tisphie@gmail.com>

---

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index fb0c215..95c7f1d 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -254,8 +254,8 @@ enum xfrm_ae_ftype_t {

 struct xfrm_userpolicy_type {
        __u8            type;
-       __u16           reserved1;
-       __u8            reserved2;
+       __u8            reserved1;
+       __u16           reserved2;
 };

 /* Netlink message attributes.  */
