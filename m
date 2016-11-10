From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/8] net: ife: Introduce new metadata tlv types
Date: Thu, 10 Nov 2016 12:23:03 +0100
Message-ID: <1478776988-5400-4-git-send-email-jiri@resnulli.us>
References: <1478776988-5400-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35073 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755209AbcKJLXP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 06:23:15 -0500
Received: by mail-wm0-f67.google.com with SMTP id a20so2466886wme.2
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 03:23:15 -0800 (PST)
In-Reply-To: <1478776988-5400-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

IFE_META_IN_IFINDEX: Allow to pass input ifindex value as part of the
ife metadata
IFE_META_OUT_IFINDEX: Allow to pass output ifindex value as part of the
ife metadata
IFE_META_ORIG_SIZE: Allow to pass the original packet size as part of
the ife metadata. Can be used in case that the packet is truncated
IFE_META_SIZE: Allow to pass the size of the encapsulated packet as
part of the ife metadata

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/ife.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/uapi/linux/ife.h b/include/uapi/linux/ife.h
index 2954da3..ebdd785 100644
--- a/include/uapi/linux/ife.h
+++ b/include/uapi/linux/ife.h
@@ -9,6 +9,10 @@ enum {
 	IFE_META_PRIO,
 	IFE_META_QMAP,
 	IFE_META_TCINDEX,
+	IFE_META_IN_IFINDEX,
+	IFE_META_OUT_IFINDEX,
+	IFE_META_ORIGSIZE,
+	IFE_META_SIZE,
 	__IFE_META_MAX
 };
 
-- 
2.7.4
