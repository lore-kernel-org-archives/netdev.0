From: Joe Perches <joe@perches.com>
Subject: [PATCH] ethtool.h: Add "structs are public" disclaimer comment
Date: Sun, 14 Mar 2010 09:17:58 -0700
Message-ID: <1268583478.30289.94.camel@Joe-Laptop.home>
References: <20100314014335.GA17208@serverengines.com>
	 <20100313.181145.211264593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ajitk@serverengines.com, ajitkhaparde@gmail.com, jeff@garzik.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1698 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085Ab0CNQSA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Mar 2010 12:18:00 -0400
In-Reply-To: <20100313.181145.211264593.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-03-13 at 18:11 -0800, David Miller wrote:
> For the millionth time, you cannot change these datastructures
> like this without breaking all existing userspace applications
> out there.

Maybe this might help reduce the broken record repetitiveness.

Signed-off-by: Joe Perches <joe@perches.com>
---
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index b33f316..9bd7583 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -10,6 +10,15 @@
  * Portions Copyright (C) Sun Microsystems 2008
  */
 
+/*
+ * Do not submit patches that change the public structs not guarded by
+ * #ifdef __KERNEL__ in this file.
+ *
+ * In case the use of __u8, __u16, __u32 and other reserved types don't
+ * mean much to you, these structs are used by user-space applications
+ * and must not be changed.
+ */
+
 #ifndef _LINUX_ETHTOOL_H
 #define _LINUX_ETHTOOL_H
 


