From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 3/6] ife: Introduce new metadata tlv types
Date: Wed, 12 Oct 2016 14:41:06 +0200
Message-ID: <1476276069-5315-4-git-send-email-jiri@resnulli.us>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33732 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754745AbcJLMl0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 08:41:26 -0400
Received: by mail-lf0-f68.google.com with SMTP id l131so4162289lfl.0
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 05:41:23 -0700 (PDT)
In-Reply-To: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotam.gi@gmail.com>

 - IFE_META_IFINDEX: Allow to pass ifindex value as part of the ife
   metadata
 - IFE_META_ORIG_SIZE: Allow to pass the original packet size as part of
   the ife metadata. Can be used in case that the packet is truncated
 - IFE_META_SIZE: Allow to pass the size of the encapsulated packet as
   part of the ife metadata

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/ife.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/uapi/linux/ife.h b/include/uapi/linux/ife.h
index abec4e0..990f29e 100644
--- a/include/uapi/linux/ife.h
+++ b/include/uapi/linux/ife.h
@@ -8,6 +8,9 @@
 #define IFE_META_PRIO 3
 #define IFE_META_QMAP 4
 #define IFE_META_TCINDEX 5
+#define IFE_META_IFINDEX 6
+#define IFE_META_ORIGSIZE 7
+#define IFE_META_SIZE 8
 
 /*Can be overridden at runtime by module option*/
 #define __IFE_META_MAX 6
-- 
2.5.5
