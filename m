From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH][TRIVIAL] net, netfilter: Remove redundant goto in
 ebt_ulog_packet
Date: Sun, 17 Jul 2011 19:56:38 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1107171953500.32359@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	coreteam@netfilter.org, netfilter@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	Bart De Schuymer <bart.de.schuymer@pandora.be>,
	trivial@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In net/bridge/netfilter/ebt_ulog.c:ebt_ulog_packet() the 'goto unlock'
before the 'alloc_failure' label is completely redundant. This patch
removes it.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/bridge/netfilter/ebt_ulog.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 26377e9..bf2a333 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -216,7 +216,6 @@ unlock:
 nlmsg_failure:
 	pr_debug("error during NLMSG_PUT. This should "
 		 "not happen, please report to author.\n");
-	goto unlock;
 alloc_failure:
 	goto unlock;
 }
-- 
1.7.6


PS. Please CC me on replies since I'm not subscribed to all the lists 
copied on this mail.

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
