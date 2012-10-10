From: Cong Wang <amwang@redhat.com>
Subject: [Patch v2 3/5] pktgen: display IPv4 address in human-readable format
Date: Wed, 10 Oct 2012 11:48:18 +0800
Message-ID: <1349840900-24138-3-git-send-email-amwang@redhat.com>
References: <1349840900-24138-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5602 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754618Ab2JJDsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 23:48:33 -0400
In-Reply-To: <1349840900-24138-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is weird to display IPv4 address in %x format, what's more,
IPv6 address is disaplayed in human-readable format too. So,
make it human-readable.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/pktgen.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 98ee549..f9b4637 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -702,8 +702,8 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 				&pkt_dev->cur_in6_saddr,
 				&pkt_dev->cur_in6_daddr);
 	} else
-		seq_printf(seq, "     cur_saddr: 0x%x  cur_daddr: 0x%x\n",
-			   pkt_dev->cur_saddr, pkt_dev->cur_daddr);
+		seq_printf(seq, "     cur_saddr: %pI4  cur_daddr: %pI4\n",
+			   &pkt_dev->cur_saddr, &pkt_dev->cur_daddr);
 
 	seq_printf(seq, "     cur_udp_dst: %d  cur_udp_src: %d\n",
 		   pkt_dev->cur_udp_dst, pkt_dev->cur_udp_src);
-- 
1.7.7.6
