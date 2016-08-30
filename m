From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 12/12] net: flow: Remove FLOWI_FLAG_L3MDEV_SRC flag
Date: Tue, 30 Aug 2016 10:34:17 -0700
Message-ID: <1472578457-26722-13-git-send-email-dsa@cumulusnetworks.com>
References: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33553 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932993AbcH3Rek (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 13:34:40 -0400
Received: by mail-pa0-f41.google.com with SMTP id cy9so9571827pac.0
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 10:34:39 -0700 (PDT)
In-Reply-To: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer used

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/flow.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index d47ef4bb5423..035aa7716967 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -34,8 +34,7 @@ struct flowi_common {
 	__u8	flowic_flags;
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_KNOWN_NH		0x02
-#define FLOWI_FLAG_L3MDEV_SRC		0x04
-#define FLOWI_FLAG_SKIP_NH_OIF		0x08
+#define FLOWI_FLAG_SKIP_NH_OIF		0x04
 	__u32	flowic_secid;
 	struct flowi_tunnel flowic_tun_key;
 };
-- 
2.1.4
