From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next] tipc: add tipc_netlink.h to uapi Kbuild
Date: Mon, 24 Nov 2014 14:24:54 +0100
Message-ID: <1416835494-7655-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:53553 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932096AbaKXN2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 08:28:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

tipc_netlink.h is the user-space header for the new netlink api. It
was accidentally left out of the uapi Kbuild list when the api was
added.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
---
 include/uapi/linux/Kbuild | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 72298b6..a1e8175 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -389,6 +389,7 @@ header-y += times.h
 header-y += timex.h
 header-y += tiocl.h
 header-y += tipc_config.h
+header-y += tipc_netlink.h
 header-y += tipc.h
 header-y += toshiba.h
 header-y += tty_flags.h
-- 
2.1.3
