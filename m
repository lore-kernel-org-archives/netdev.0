From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] net: filter: replace sk_run_filter with __bpf_prog_run in comments
Date: Fri, 10 Oct 2014 11:37:11 +0800
Message-ID: <1412912231-1004-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:55187 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbaJJDhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 23:37:19 -0400
Received: by mail-pa0-f48.google.com with SMTP id eu11so897870pac.35
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 20:37:17 -0700 (PDT)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id on3sm1873013pdb.71.2014.10.09.20.37.16
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 09 Oct 2014 20:37:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com> 

sk_run_filter has been renamed as __bpf_prog_run, so replace them in comments

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/core/filter.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index fcd3f67..9324601 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -51,9 +51,9 @@
  *	@skb: buffer to filter
  *
  * Run the filter code and then cut skb->data to correct size returned by
- * sk_run_filter. If pkt_len is 0 we toss packet. If skb->len is smaller
+ * __bpf_prog_run. If pkt_len is 0 we toss packet. If skb->len is smaller
  * than pkt_len we keep whole skb->data. This is the socket level
- * wrapper to sk_run_filter. It returns 0 if the packet should
+ * wrapper to __bpf_prog_run. It returns 0 if the packet should
  * be accepted or -EPERM if the packet should be tossed.
  *
  */
@@ -567,10 +567,10 @@ err:
 /* Security:
  *
  * A BPF program is able to use 16 cells of memory to store intermediate
- * values (check u32 mem[BPF_MEMWORDS] in sk_run_filter()).
+ * values (check u32 mem[BPF_MEMWORDS] in __bpf_prog_run()).
  *
  * As we dont want to clear mem[] array for each packet going through
- * sk_run_filter(), we check that filter loaded by user never try to read
+ * __bpf_prog_run(), we check that filter loaded by user never try to read
  * a cell if not previously written, and we check all branches to be sure
  * a malicious user doesn't try to abuse us.
  */
-- 
1.7.10.4
