From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] decnet: compile fix for removal of byteorder wrapper
Date: Thu, 27 Nov 2008 17:41:18 -0800
Message-ID: <1227836478.5477.2.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Oeser <ioe-lkml@rameria.de>,
	Steven Whitehouse <swhiteho@redhat.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:9889 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016AbYK1BlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 20:41:25 -0500
Received: by wf-out-1314.google.com with SMTP id 27so1232600wfd.4
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2008 17:41:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Sorry Dave, I actually had a dirty working tree with an extra
copy of unaligned.h as unalignedh so it compiled here.

 include/net/dn.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/dn.h b/include/net/dn.h
index 7cd6bb8..e5469f7 100644
--- a/include/net/dn.h
+++ b/include/net/dn.h
@@ -4,7 +4,7 @@
 #include <linux/dn.h>
 #include <net/sock.h>
 #include <asm/byteorder.h>
-#include <asm/unalignedh>
+#include <asm/unaligned.h>
 
 struct dn_scp                                   /* Session Control Port */
 {
-- 
1.6.0.4.1044.g77718



