From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 01/13] batman-adv: Fix kernel panic when
	fetching vis data on a vis server
Date: Sat, 29 Jan 2011 22:47:28 +0100
Message-ID: <1296337660-12376-2-git-send-email-sven@narfation.org>
References: <1296337660-12376-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1296337660-12376-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>

The hash_iterate removal introduced a bug leading to a kernel panic when
fetching the vis data on a vis server. That commit forgot to rename one
variable name, which this commit fixes now.

Reported-by: Russell Senior <russell-LS+HbC+WUqwFvAYqzeGVJV6hYfS7NtTn@public.gmane.org>
Signed-off-by: Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/vis.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index cd4c423..f69a374 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -268,10 +268,10 @@ int vis_seq_print_text(struct seq_file *seq, void *=
offset)
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
