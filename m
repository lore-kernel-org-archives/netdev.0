From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH v3 02/10] pktgen: adjust spacing in proc file
	interface output
Date: Thu, 21 May 2015 12:16:11 +0200
Message-ID: <20150521101606.15148.29214.stgit@ivy>
References: <20150521101501.15148.10609.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53072 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751856AbbEUKQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 06:16:46 -0400
In-Reply-To: <20150521101501.15148.10609.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Too many spaces were introduced in commit 63adc6fb8ac0 ("pktgen: cleanup
checkpatch warnings"), thus misaligning "src_min:" to other columns.

Fixes: 63adc6fb8ac0 ("pktgen: cleanup checkpatch warnings")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/core/pktgen.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 62f9799..167e592 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -572,7 +572,7 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 			   "     dst_min: %s  dst_max: %s\n",
 			   pkt_dev->dst_min, pkt_dev->dst_max);
 		seq_printf(seq,
-			   "        src_min: %s  src_max: %s\n",
+			   "     src_min: %s  src_max: %s\n",
 			   pkt_dev->src_min, pkt_dev->src_max);
 	}
 
