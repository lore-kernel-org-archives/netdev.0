From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH 15/15] dropmon: remove duplicated #include
Date: Sat, 11 Jul 2009 09:33:49 +0800
Message-ID: <1247276029-1096-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f193.google.com ([209.85.216.193]:49442 "EHLO
	mail-px0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbZGKBd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2009 21:33:58 -0400
Received: by pxi31 with SMTP id 31so866359pxi.33
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2009 18:33:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated #include('s) in
  include/linux/net_dropmon.h

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 include/linux/net_dropmon.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/net_dropmon.h b/include/linux/net_dropmon.h
index 3ceb0cc..2a73946 100644
--- a/include/linux/net_dropmon.h
+++ b/include/linux/net_dropmon.h
@@ -3,7 +3,6 @@
 
 #include <linux/types.h>
 #include <linux/netlink.h>
-#include <linux/types.h>
 
 struct net_dm_drop_point {
 	__u8 pc[8];
-- 
1.6.1.2

