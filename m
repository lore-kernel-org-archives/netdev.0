From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH] net: filter: minor: fix kdoc in __sk_run_filter
Date: Tue,  1 Apr 2014 19:38:01 +0200
Message-ID: <c632c48561df232d14dd87d68b3b322db110e8aa.1396373788.git.dborkman@redhat.com>
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org, ast@plumgrid.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37711 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751336AbaDARiM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 13:38:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This minor patch fixes the following warning when doing
a `make htmldocs`:

  DOCPROC Documentation/DocBook/networking.xml
Warning(.../net/core/filter.c:135): No description found for parameter 'insn'
Warning(.../net/core/filter.c:135): Excess function parameter 'fentry' description in '__sk_run_filter'
  HTML    Documentation/DocBook/networking.html

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/filter.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 3733381..765556b 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -125,10 +125,10 @@ noinline u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 /**
  *	__sk_run_filter - run a filter on a given context
  *	@ctx: buffer to run the filter on
- *	@fentry: filter to apply
+ *	@insn: filter to apply
  *
  * Decode and apply filter instructions to the skb->data. Return length to
- * keep, 0 for none. @ctx is the data we are operating on, @filter is the
+ * keep, 0 for none. @ctx is the data we are operating on, @insn is the
  * array of filter instructions.
  */
 unsigned int __sk_run_filter(void *ctx, const struct sock_filter_int *insn)
-- 
1.7.11.7
