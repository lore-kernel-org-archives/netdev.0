From: "G.Balaji" <balajig81@gmail.com>
Subject: [PATCH] bridge: Fix compilation warning in function br_stp_recalculate_bridge_id()
Date: Tue, 29 Mar 2011 21:50:04 +0530
Message-ID: <1301415604-3871-1-git-send-email-balajig81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	"G.Balaji" <balajig81@gmail.com>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:54492 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750Ab1C2QUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 12:20:25 -0400
Received: by yia27 with SMTP id 27so144364yia.19
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2011 09:20:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/bridge/br_stp_if.c: In function =E2=80=98br_stp_recalculate_bridge_=
id=E2=80=99:
net/bridge/br_stp_if.c:216:3: warning: =E2=80=98return=E2=80=99 with no=
 value, in function returning non-void

Signed-off-by: G.Balaji <balajig81@gmail.com>
---
 net/bridge/br_stp_if.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 5593f5a..9b61d09 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -213,7 +213,7 @@ bool br_stp_recalculate_bridge_id(struct net_bridge=
 *br)
=20
 	/* user has chosen a value so keep it */
 	if (br->flags & BR_SET_MAC_ADDR)
-		return;
+		return false;
=20
 	list_for_each_entry(p, &br->port_list, list) {
 		if (addr =3D=3D br_mac_zero ||
--=20
1.7.4

