From: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Subject: [PATCH] sch_sfb.c: fix typo in compute_qlen.
Date: Fri, 11 Apr 2008 22:30:52 +0200
Message-ID: <7ik5j4cewz.fsf@lanthane.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:58067 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761433AbYDKUa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 16:30:56 -0400
Received: from hydrogene.pps.jussieu.fr (hydrogene.pps.jussieu.fr [134.157.168.1])
          by shiva.jussieu.fr (8.14.2/jtpda-5.4) with ESMTP id m3BKUrBA015113
          for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 22:30:54 +0200 (CEST)
Received: from lanthane.pps.jussieu.fr (Debian-exim@lanthane.pps.jussieu.fr [134.157.168.57])
          by hydrogene.pps.jussieu.fr (8.13.4/jtpda-5.4) with ESMTP id m3BKUqtw008383
          for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 22:30:52 +0200
Received: from jch by lanthane.pps.jussieu.fr with local (Exim 4.69)
	(envelope-from <jch@lanthane.pps.jussieu.fr>)
	id 1JkPtc-0002jA-1s
	for netdev@vger.kernel.org; Fri, 11 Apr 2008 22:30:52 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Of course, this depends on the SFB patch being applied.

                                        Juliusz

diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index b17d35f..f3e1e07 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -202,7 +202,7 @@ static void compute_qlen(u16 *qlen_r, u16 *prob_r, struct sfb_sched_data *q)
                for (j = 0; j < NUMBUCKETS; j++) {
                        if (qlen < q->buckets[filter][i][j].qlen)
                                qlen = q->buckets[filter][i][j].qlen;
-                       if (qlen < q->buckets[filter][i][j].pm)
+                       if (prob < q->buckets[filter][i][j].pm)
                                prob = q->buckets[filter][i][j].pm;
                }
        }
