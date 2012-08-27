From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH] iproute2: build failure due to missing '\' in Makefile
Date: Mon, 27 Aug 2012 10:50:31 -0700
Message-ID: <20120827175031.8539.56527.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:16804 "EHLO mga01.intel.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750971Ab2H0SGo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2012 14:06:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After latest commit 'Install all tc and ip sub pages' this error
occurs on make.

make[2]: Nothing to be done for `all'.
make[2]: Leaving directory `/home/git/kernel.org/iproute2/man/man3'
make[2]: Entering directory `/home/git/kernel.org/iproute2/man/man8'
Makefile:8: *** commands commence before first target.  Stop.
make[2]: Leaving directory `/home/git/kernel.org/iproute2/man/man8'

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 man/man8/Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 1410bf7..d021da2 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -4,7 +4,7 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	tc-bfifo.8 tc-cbq.8 tc-cbq-details.8 tc-choke.8 tc-codel.8 \
 	tc-drr.8 tc-ematch.8 tc-fq_codel.8 tc-hfsc.8 tc-htb.8 \
 	tc-netem.8 tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 \
-	tc-sfb.8 tc-sfq.8 tc-stab.8 tc-tbf.8
+	tc-sfb.8 tc-sfq.8 tc-stab.8 tc-tbf.8 \
 	bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
 	ip-address.8 ip-addrlabel.8 ip-l2tp.8 ip-link.8 \
 	ip-maddress.8 ip-monitor.8 ip-mroute.8 ip-neighbour.8 \
