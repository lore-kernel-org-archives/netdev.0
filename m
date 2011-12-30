From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/7] unix_diag: Include unix_diag.h into header-y target
Date: Fri, 30 Dec 2011 14:52:51 +0400
Message-ID: <4EFD9803.3040106@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:14723 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750881Ab1L3Kw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Dec 2011 05:52:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The headers check complains it should include the linux/types.h
withing, thus add this one.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/Kbuild      |    1 +
 include/linux/unix_diag.h |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 8e484d6..c94e717 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -197,6 +197,7 @@ header-y += in6.h
 header-y += in_route.h
 header-y += sock_diag.h
 header-y += inet_diag.h
+header-y += unix_diag.h
 header-y += inotify.h
 header-y += input.h
 header-y += ioctl.h
diff --git a/include/linux/unix_diag.h b/include/linux/unix_diag.h
index 3f7afb0..a5ce0f3 100644
--- a/include/linux/unix_diag.h
+++ b/include/linux/unix_diag.h
@@ -1,6 +1,8 @@
 #ifndef __UNIX_DIAG_H__
 #define __UNIX_DIAG_H__
 
+#include <linux/types.h>
+
 struct unix_diag_req {
 	__u8	sdiag_family;
 	__u8	sdiag_protocol;
-- 
1.5.5.6
