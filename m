From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: make bonding slaves honour master's skb->priority
Date: Mon, 24 Oct 2011 21:41:00 -0700
Message-ID: <1319517660-22085-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:64365 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212Ab1JYElO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 00:41:14 -0400
Received: by pzk36 with SMTP id 36so343592pzk.1
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 21:41:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Change-Id: Ieea6ff9aacacb1eb8c52308c8bfe091acbfc09b2
Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 drivers/net/bonding/bond_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 41430ba..2cbc2f8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -395,7 +395,6 @@ int bond_dev_queue_xmit(struct bonding *bond, struc=
t sk_buff *skb,
 			struct net_device *slave_dev)
 {
 	skb->dev =3D slave_dev;
-	skb->priority =3D 1;
=20
 	skb->queue_mapping =3D bond_queue_mapping(skb);
=20
--=20
1.7.3.1
