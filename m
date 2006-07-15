From: Dave Jones <davej@redhat.com>
Subject: sch_htb compile fix.
Date: Sat, 15 Jul 2006 03:41:12 -0400
Message-ID: <20060715074112.GA18210@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@osdl.org>,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:19687 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1946004AbWGOHlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jul 2006 03:41:17 -0400
To: Linux Kernel <linux-kernel@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/sched/sch_htb.c: In function 'htb_change_class':
net/sched/sch_htb.c:1605: error: expected ';' before 'do_gettimeofday'

Signed-off-by: Dave Jones <davej@redhat.com>

--- linux-2.6.17.noarch/net/sched/sch_htb.c~	2006-07-15 03:40:14.000000000 -0400
+++ linux-2.6.17.noarch/net/sched/sch_htb.c	2006-07-15 03:40:21.000000000 -0400
@@ -1601,7 +1601,7 @@ static int htb_change_class(struct Qdisc
 		/* set class to be in HTB_CAN_SEND state */
 		cl->tokens = hopt->buffer;
 		cl->ctokens = hopt->cbuffer;
-		cl->mbuffer = PSCHED_JIFFIE2US(HZ*60) /* 1min */
+		cl->mbuffer = PSCHED_JIFFIE2US(HZ*60); /* 1min */
 		PSCHED_GET_TIME(cl->t_c);
 		cl->cmode = HTB_CAN_SEND;
-- 
http://www.codemonkey.org.uk
