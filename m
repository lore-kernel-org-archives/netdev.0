From: David Ahern <dsahern@gmail.com>
Subject: [PATCH] net: Remove remaining remnants of pm_qos from netdevice.h
Date: Sat,  9 May 2015 16:21:43 -0600
Message-ID: <1431210103-18683-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>, Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:36485 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbbEIWWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 18:22:04 -0400
Received: by iecmd7 with SMTP id md7so8344659iec.3
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 15:22:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e2c6544829f removed pm_qos from struct net_device but left the
comment above header file. Remove those.

Signed-off-by: David Ahern <dsahern@gmail.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
 include/linux/netdevice.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1899c74a7127..05b9a694e213 100644
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
