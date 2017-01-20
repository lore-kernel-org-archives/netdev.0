From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: [PATCH net-next] uapi: fix signess in ethtool_validate_speed()
Date: Fri, 20 Jan 2017 14:20:53 +0100
Message-ID: <1484918453-5849-1-git-send-email-volodymyr.bendiuga@gmail.com>
Cc: Jonas Johansson <jonas.johansson@westermo.se>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
To: davem@davemloft.net, mst@redhat.com, nikolay@cumulusnetworks.com,
        netdev@vger.kernel.org, volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33377 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750893AbdATNVu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 08:21:50 -0500
Received: by mail-lf0-f65.google.com with SMTP id x1so8642114lff.0
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 05:21:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Johansson <jonas.johansson@westermo.se>

There is a comparison of speed  variable which
is unsigned, and SPEED_UNKNOWN which is signed.

Signed-off-by: Jonas Johansson <jonas.johansson@westermo.se>
Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
---
 include/uapi/linux/ethtool.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index f0db778..1ca4a77 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1500,7 +1500,7 @@ enum ethtool_link_mode_bit_indices {
 
 #define SPEED_UNKNOWN		-1
 
-static inline int ethtool_validate_speed(__u32 speed)
+static inline int ethtool_validate_speed(__s32 speed)
 {
 	return speed <= INT_MAX || speed == SPEED_UNKNOWN;
 }
-- 
2.7.4
