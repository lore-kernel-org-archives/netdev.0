From: kaber@trash.net
Subject: [PATCH 17/79] IPVS: Make the cp argument to ip_vs_sync_conn() static
Date: Wed, 19 Jan 2011 20:14:17 +0100
Message-ID: <1295464519-21763-18-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>

Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    2 +-
 net/netfilter/ipvs/ip_vs_sync.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index be2b569..d5a32e4 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -916,7 +916,7 @@ extern char ip_vs_master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 extern char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 extern int start_sync_thread(int state, char *mcast_ifn, __u8 syncid);
 extern int stop_sync_thread(int state);
-extern void ip_vs_sync_conn(struct ip_vs_conn *cp);
+extern void ip_vs_sync_conn(const struct ip_vs_conn *cp);
 
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index ab85aed..a4dccbc 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -236,7 +236,7 @@ get_curr_sync_buff(unsigned long time)
  *      Add an ip_vs_conn information into the current sync_buff.
  *      Called by ip_vs_in.
  */
-void ip_vs_sync_conn(struct ip_vs_conn *cp)
+void ip_vs_sync_conn(const struct ip_vs_conn *cp)
 {
 	struct ip_vs_sync_mesg *m;
 	struct ip_vs_sync_conn *s;
-- 
1.7.2.3

