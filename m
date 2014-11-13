From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] FOU: Fix no return statement warning for !CONFIG_NET_FOU_IP_TUNNELS
Date: Thu, 13 Nov 2014 12:48:21 +0100
Message-ID: <8cf12c98c1a9606f2bd69dd9c108d76f444ab79e.1415879256.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51237 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932682AbaKMLsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 06:48:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv4/fou.c: In function =E2=80=98ip_tunnel_encap_del_fou_ops=E2=80=99=
:
net/ipv4/fou.c:861:1: warning: no return statement in function returnin=
g non-void [-Wreturn-type]

=46ixes: a8c5f90fb5 ("ip_tunnel: Ops registration for secondary encap (=
fou, gue)")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv4/fou.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index fe09077..b0b436b 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -856,7 +856,7 @@ static int ip_tunnel_encap_add_fou_ops(void)
 	return 0;
 }
=20
-static int ip_tunnel_encap_del_fou_ops(void)
+static void ip_tunnel_encap_del_fou_ops(void)
 {
 }
=20
--=20
1.9.3
