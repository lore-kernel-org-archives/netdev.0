From: David Ahern <dsahern@gmail.com>
Subject: [PATCH 2/2] net: Remove remaining remnants of pm_qos from netdevice.h
Date: Tue, 12 May 2015 09:37:00 -0600
Message-ID: <1431445020-25235-2-git-send-email-dsahern@gmail.com>
References: <1431445020-25235-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>, Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:34208 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507AbbELPhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:37:19 -0400
Received: by iecmd7 with SMTP id md7so4702865iec.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:37:19 -0700 (PDT)
In-Reply-To: <1431445020-25235-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e2c6544829f removed pm_qos from struct net_device but left the
comment and header file. Remove those.

Signed-off-by: David Ahern <dsahern@gmail.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
 include/linux/netdevice.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a6d706b2a947..6317012ec1e1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -25,7 +25,6 @@
 #ifndef _LINUX_NETDEVICE_H
 #define _LINUX_NETDEVICE_H
 
-#include <linux/pm_qos.h>
 #include <linux/timer.h>
 #include <linux/bug.h>
 #include <linux/delay.h>
@@ -1499,8 +1498,6 @@ enum netdev_priv_flags {
  *
  *	@qdisc_tx_busylock:	XXX: need comments on this one
  *
- *	@pm_qos_req:	Power Management QoS object
- *
  *	FIXME: cleanup struct net_device such that network protocol info
  *	moves out.
  */
-- 
2.2.1
