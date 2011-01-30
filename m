From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 1/4] batman-adv: Fix kernel panic when fetching vis data on a vis server
Date: Sun, 30 Jan 2011 13:11:41 +0100
Message-ID: <1296389504-11208-2-git-send-email-sven@narfation.org>
References: <1296389504-11208-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:45220 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752768Ab1A3MLw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jan 2011 07:11:52 -0500
In-Reply-To: <1296389504-11208-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

The hash_iterate removal introduced a bug leading to a kernel panic whe=
n
fetching the vis data on a vis server. That commit forgot to rename one
variable name, which this commit fixes now.

Reported-by: Russell Senior <russell@personaltelco.net>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/vis.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index cd4c423..f69a374 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -268,10 +268,10 @@ int vis_seq_print_text(struct seq_file *seq, void=
 *offset)
 				buff_pos +=3D sprintf(buff + buff_pos, "%pM,",
 						entry->addr);
=20
-				for (i =3D 0; i < packet->entries; i++)
+				for (j =3D 0; j < packet->entries; j++)
 					buff_pos +=3D vis_data_read_entry(
 							buff + buff_pos,
-							&entries[i],
+							&entries[j],
 							entry->addr,
 							entry->primary);
=20
--=20
1.7.2.3

