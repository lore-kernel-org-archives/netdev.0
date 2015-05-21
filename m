From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH v2 02/10] pktgen: adjust spacing in proc file
	interface output
Date: Thu, 21 May 2015 12:11:56 +0200
Message-ID: <20150521101152.15044.27885.stgit@ivy>
References: <20150521101003.15044.82190.stgit@ivy>
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
Received: from mx1.redhat.com ([209.132.183.28]:35995 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751750AbbEUKM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 06:12:29 -0400
In-Reply-To: <20150521101003.15044.82190.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Too many spaces were introduced in commit 63adc6fb8ac0 ("pktgen: cleanup
checkpatch warnings"), thus misaligning "src_min:" to other columns.

Fixes: 63adc6fb8ac0 ("pktgen: cleanup checkpatch warnings")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 0 files changed, 0 insertions(+), 0 deletions(-)

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
 
