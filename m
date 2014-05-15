From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net 3/3] pktgen: disable IPv6 when we want to use IPv4
Date: Thu, 15 May 2014 17:46:37 +0800
Message-ID: <1400147197-22445-3-git-send-email-liuhangbin@gmail.com>
References: <1400147197-22445-1-git-send-email-liuhangbin@gmail.com>
Cc: Francesco Fondelli <francesco.fondelli@gmail.com>,
	netdev@vger.kernel.org, Hangbin Liu <liuhangbin@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:65308 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530AbaEOJrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 05:47:05 -0400
Received: by mail-pa0-f44.google.com with SMTP id ld10so869254pab.17
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 02:47:05 -0700 (PDT)
In-Reply-To: <1400147197-22445-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/core/pktgen.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 1809bdf..fabd17e 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1264,6 +1264,8 @@ static ssize_t pktgen_if_write(struct file *file,
 		if (len < 0)
 			return len;
 
+		pkt_dev->flags &= ~F_IPV6;
+
 		if (copy_from_user(buf, &user_buffer[i], len))
 			return -EFAULT;
 		buf[len] = 0;
@@ -1284,6 +1286,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		if (len < 0)
 			return len;
 
+		pkt_dev->flags &= ~F_IPV6;
 
 		if (copy_from_user(buf, &user_buffer[i], len))
 			return -EFAULT;
@@ -1395,6 +1398,8 @@ static ssize_t pktgen_if_write(struct file *file,
 		if (len < 0)
 			return len;
 
+		pkt_dev->flags &= ~F_IPV6;
+
 		if (copy_from_user(buf, &user_buffer[i], len))
 			return -EFAULT;
 		buf[len] = 0;
@@ -1415,6 +1420,8 @@ static ssize_t pktgen_if_write(struct file *file,
 		if (len < 0)
 			return len;
 
+		pkt_dev->flags &= ~F_IPV6;
+
 		if (copy_from_user(buf, &user_buffer[i], len))
 			return -EFAULT;
 		buf[len] = 0;
-- 
1.8.1.4
