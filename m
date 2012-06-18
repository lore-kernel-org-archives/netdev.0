From: Daniel Halperin <dhalperi@cs.washington.edu>
Subject: [PATCH] sctp: fix warning when compiling without IPv6
Date: Mon, 18 Jun 2012 14:04:55 -0700
Message-ID: <B7062EEE-046D-4435-B5FC-54FF3F763645@cs.washington.edu>
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:42995 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225Ab2FRVE7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 17:04:59 -0400
Received: by pbbrp8 with SMTP id rp8so8717120pbb.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 14:04:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/sctp/protocol.c: In function =91sctp_addr_wq_timeout_handler=92:
net/sctp/protocol.c:676: warning: label =91free_next=92 defined but not=
 used

Signed-off-by: Daniel Halperin <dhalperi@cs.washington.edu>
---
 net/sctp/protocol.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 5942d27..9c90811 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -673,7 +673,9 @@ void sctp_addr_wq_timeout_handler(unsigned long arg=
)
 				SCTP_DEBUG_PRINTK("sctp_addrwq_timo_handler: sctp_asconf_mgmt fail=
ed\n");
 			sctp_bh_unlock_sock(sk);
 		}
+#if IS_ENABLED(CONFIG_IPV6)
 free_next:
+#endif
 		list_del(&addrw->list);
 		kfree(addrw);
 	}
--=20
1.7.0.4
