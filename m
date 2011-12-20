From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [PATCH net-next] net: unix -- Add missing module.h inclusion
Date: Tue, 20 Dec 2011 18:33:03 +0400
Message-ID: <20111220143303.GA12782@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>
To: NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:53483 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab1LTOdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 09:33:08 -0500
Received: by eekc4 with SMTP id c4so6571820eek.19
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 06:33:07 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise getting

 | net/unix/diag.c:312:16: error: expected declaration specifiers or =E2=
=80=98...=E2=80=99 before string constant
 | net/unix/diag.c:313:1: error: expected declaration specifiers or =E2=
=80=98...=E2=80=99 before string constant

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 net/unix/diag.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/unix/diag.c b/net/unix/diag.c
index a5c4aab..91d5782 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -3,6 +3,7 @@
 #include <linux/sock_diag.h>
 #include <linux/unix_diag.h>
 #include <linux/skbuff.h>
+#include <linux/module.h>
 #include <net/netlink.h>
 #include <net/af_unix.h>
 #include <net/tcp_states.h>
--=20
1.7.7.4
