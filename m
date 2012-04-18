From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] net/sock.h: fix sk_peek_off kernel-doc warning
Date: Tue, 17 Apr 2012 17:03:53 -0700
Message-ID: <4F8E04E9.7030607@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy1-pub.bluehost.com ([66.147.249.253]:46890 "HELO
	oproxy1-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753673Ab2DRADQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 20:03:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>

Fix kernel-doc warning in net/sock.h:

Warning(include/net/sock.h:377): No description found for parameter 'sk_peek_off'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 include/net/sock.h |    1 +
 1 file changed, 1 insertion(+)

--- lnx-34-rc3.orig/include/net/sock.h
+++ lnx-34-rc3/include/net/sock.h
@@ -246,6 +246,7 @@ struct cg_proto;
   *	@sk_user_data: RPC layer private data
   *	@sk_sndmsg_page: cached page for sendmsg
   *	@sk_sndmsg_off: cached offset for sendmsg
+  *	@sk_peek_off: current peek_offset value
   *	@sk_send_head: front of stuff to transmit
   *	@sk_security: used by security modules
   *	@sk_mark: generic packet mark
