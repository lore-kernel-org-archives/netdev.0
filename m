From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/12] netrom:  Reduce switch/case indent
Date: Fri,  1 Jul 2011 12:43:10 -0700
Message-ID: <0e287994408ee50d5f10170e0c14e625faa6625e.1309549244.git.joe@perches.com>
References: <cover.1309549243.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <cover.1309549243.git.joe@perches.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the case labels the same indent as the switch.

git diff -w shows code on same line as case moved
to separate lines and a "/* Fallthrough */" comment
added where appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netrom/nr_route.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
index 44059d0..cd5ddb2 100644
--- a/net/netrom/nr_route.c
+++ b/net/netrom/nr_route.c
@@ -257,9 +257,12 @@ static int __must_check nr_add_node(ax25_address *nr, const char *mnemonic,
 	case 3:
 		if (nr_node->routes[1].quality > nr_node->routes[0].quality) {
 			switch (nr_node->which) {
-				case 0:  nr_node->which = 1; break;
-				case 1:  nr_node->which = 0; break;
-				default: break;
+			case 0:
+				nr_node->which = 1;
+				break;
+			case 1:
+				nr_node->which = 0;
+				break;
 			}
 			nr_route           = nr_node->routes[0];
 			nr_node->routes[0] = nr_node->routes[1];
@@ -505,12 +508,13 @@ static int nr_dec_obs(void)
 				s->count--;
 
 				switch (i) {
-					case 0:
-						s->routes[0] = s->routes[1];
-					case 1:
-						s->routes[1] = s->routes[2];
-					case 2:
-						break;
+				case 0:
+					s->routes[0] = s->routes[1];
+					/* Fallthrough */
+				case 1:
+					s->routes[1] = s->routes[2];
+				case 2:
+					break;
 				}
 				break;
 
-- 
1.7.6.rc1

