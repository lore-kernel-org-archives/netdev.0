From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH 10/14] kernel-doc: fix new warning in net/sock.h
Date: Sat, 21 Jan 2012 11:03:10 -0800
Message-ID: <4F1B0BEE.6000205@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix new kernel-doc warning:

Warning(include/net/sock.h:372): No description found for parameter 'sk_cgrp_prioidx'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 include/net/sock.h |    1 +
 1 file changed, 1 insertion(+)

--- lnx-33-rc1.orig/include/net/sock.h
+++ lnx-33-rc1/include/net/sock.h
@@ -226,6 +226,7 @@ struct cg_proto;
   *	@sk_ack_backlog: current listen backlog
   *	@sk_max_ack_backlog: listen backlog set in listen()
   *	@sk_priority: %SO_PRIORITY setting
+  *	@sk_cgrp_prioidx: socket group's priority map index
   *	@sk_type: socket type (%SOCK_STREAM, etc)
   *	@sk_protocol: which protocol this socket belongs in this network family
   *	@sk_peer_pid: &struct pid for this socket's peer
