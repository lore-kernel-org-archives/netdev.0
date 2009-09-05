From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] netlink: silence compiler warning
Date: Fri, 04 Sep 2009 20:55:46 -0400
Message-ID: <4AA1B712.6060900@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:26069 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933786AbZIEA4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 20:56:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  CC      net/netlink/genetlink.o
net/netlink/genetlink.c: In function =91genl_register_mc_group=92:
net/netlink/genetlink.c:139: warning: =91err=92 may be used uninitializ=
ed in this function

=46rom following the code 'err' is initialized, but set it to zero to
silence the warning.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 575c643..66f6ba0 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -136,7 +136,7 @@ int genl_register_mc_group(struct genl_family *fami=
ly,
 {
 	int id;
 	unsigned long *new_groups;
-	int err;
+	int err =3D 0;
=20
 	BUG_ON(grp->name[0] =3D=3D '\0');
