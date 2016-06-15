From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH] tipc: eliminate uninitialized variable warning
Date: Wed, 15 Jun 2016 14:11:31 +0800
Message-ID: <1465971091-16695-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <jon.maloy@ericsson.com>, <erik.hugne@gmail.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:41228 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986AbcFOGMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 02:12:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/tipc/link.c: In function =E2=80=98tipc_link_timeout=E2=80=99:
net/tipc/link.c:744:28: warning: =E2=80=98mtyp=E2=80=99 may be used uni=
nitialized in this function [-Wuninitialized]

=46ixes: 42b18f605fea ("tipc: refactor function tipc_link_timeout()")
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 7059c94..67b6ab9 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -704,7 +704,8 @@ static void link_profile_stats(struct tipc_link *l)
  */
 int tipc_link_timeout(struct tipc_link *l, struct sk_buff_head *xmitq)
 {
-	int mtyp, rc =3D 0;
+	int mtyp =3D 0;
+	int rc =3D 0;
 	bool state =3D false;
 	bool probe =3D false;
 	bool setup =3D false;
--=20
1.7.9.5
