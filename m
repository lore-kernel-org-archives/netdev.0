From: jamal <hadi@cyberus.ca>
Subject: bk16 changes to cbq
Date: 03 Jul 2004 09:36:50 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1088861810.1039.298.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey <kuznet@ms2.inr.ac.ru>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I am noticing this in bk16; it may be one of the changes that came 
from Stephen recently..

--- a/net/sched/sch_cbq.c       2004-02-20 18:37:25 -08:00
+++ b/net/sched/sch_cbq.c       2004-06-18 13:51:18 -07:00
@@ -1054,7 +1054,7 @@
 
        if (sch->q.qlen) {
                sch->stats.overlimits++;
-               if (q->wd_expires && !netif_queue_stopped(sch->dev)) {
+               if (q->wd_expires) {
                        long delay = PSCHED_US2JIFFIE(q->wd_expires);
                        if (delay <= 0)
                                delay = 1;

What i remember is this (4-5 years back) used to cure a bug - cant
remember the details unfortunately, but Alexey may remember.
I am hoping removal of the above line implies that those conditions dont
exist anymore? 

At the expense of repeating a discussion that may have already happened,
what was the logic for removing this line?

cheers,
jamal
