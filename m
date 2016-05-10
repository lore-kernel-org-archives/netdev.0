From: tcharding <me@tobin.cc>
Subject: [PATCH 1/3] bridge: netfilter: checkpatch whitespace fixes
Date: Tue, 10 May 2016 11:26:56 +1000
Message-ID: <1462843618-21914-2-git-send-email-me@tobin.cc>
References: <1462843618-21914-1-git-send-email-me@tobin.cc>
Cc: Tobin C Harding <me@tobin.cc>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462843618-21914-1-git-send-email-me@tobin.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tobin C Harding <me@tobin.cc>

checkpatch produces various white space 'checks'.

This patch amends them.

Signed-off-by: Tobin C Harding <me@tobin.cc>
---
This is my second linux kernel patch. Unsure if I was meant to cc multiple mailing lists?

thanks

 net/bridge/netfilter/ebt_stp.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 6b731e1..26a0859 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -55,65 +55,65 @@ static bool ebt_filter_config(const struct ebt_stp_info *info,
 	if (info->bitmask & EBT_STP_ROOTPRIO) {
 		v16 = NR16(stpc->root);
 		if (FWINV(v16 < c->root_priol ||
-		    v16 > c->root_priou, EBT_STP_ROOTPRIO))
+			  v16 > c->root_priou, EBT_STP_ROOTPRIO))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_ROOTADDR) {
 		verdict = 0;
 		for (i = 0; i < 6; i++)
-			verdict |= (stpc->root[2+i] ^ c->root_addr[i]) &
-				   c->root_addrmsk[i];
+			verdict |= (stpc->root[2 + i] ^ c->root_addr[i]) &
+				c->root_addrmsk[i];
 		if (FWINV(verdict != 0, EBT_STP_ROOTADDR))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_ROOTCOST) {
 		v32 = NR32(stpc->root_cost);
 		if (FWINV(v32 < c->root_costl ||
-		    v32 > c->root_costu, EBT_STP_ROOTCOST))
+			  v32 > c->root_costu, EBT_STP_ROOTCOST))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_SENDERPRIO) {
 		v16 = NR16(stpc->sender);
 		if (FWINV(v16 < c->sender_priol ||
-		    v16 > c->sender_priou, EBT_STP_SENDERPRIO))
+			  v16 > c->sender_priou, EBT_STP_SENDERPRIO))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_SENDERADDR) {
 		verdict = 0;
 		for (i = 0; i < 6; i++)
-			verdict |= (stpc->sender[2+i] ^ c->sender_addr[i]) &
-				   c->sender_addrmsk[i];
+			verdict |= (stpc->sender[2 + i] ^ c->sender_addr[i]) &
+				c->sender_addrmsk[i];
 		if (FWINV(verdict != 0, EBT_STP_SENDERADDR))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_PORT) {
 		v16 = NR16(stpc->port);
 		if (FWINV(v16 < c->portl ||
-		    v16 > c->portu, EBT_STP_PORT))
+			  v16 > c->portu, EBT_STP_PORT))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_MSGAGE) {
 		v16 = NR16(stpc->msg_age);
 		if (FWINV(v16 < c->msg_agel ||
-		    v16 > c->msg_ageu, EBT_STP_MSGAGE))
+			  v16 > c->msg_ageu, EBT_STP_MSGAGE))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_MAXAGE) {
 		v16 = NR16(stpc->max_age);
 		if (FWINV(v16 < c->max_agel ||
-		    v16 > c->max_ageu, EBT_STP_MAXAGE))
+			  v16 > c->max_ageu, EBT_STP_MAXAGE))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_HELLOTIME) {
 		v16 = NR16(stpc->hello_time);
 		if (FWINV(v16 < c->hello_timel ||
-		    v16 > c->hello_timeu, EBT_STP_HELLOTIME))
+			  v16 > c->hello_timeu, EBT_STP_HELLOTIME))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_FWDD) {
 		v16 = NR16(stpc->forward_delay);
 		if (FWINV(v16 < c->forward_delayl ||
-		    v16 > c->forward_delayu, EBT_STP_FWDD))
+			  v16 > c->forward_delayu, EBT_STP_FWDD))
 			return false;
 	}
 	return true;
-- 
2.8.2

