From: S P <speattle@yahoo.com>
Subject: [PATCH] linux 2.6.x.x net/sched/sch_api.c -- more comment reviews
Date: Mon, 13 Sep 2004 14:59:44 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913215944.33830.qmail@web90010.mail.scd.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OK,
I used 'diff -Nru' this time.
Sorry about last time.  Ignorance~~~  :)

Tense in the doc goes back and forth, making it a
little difficult to understand.

I hope I understood the documentation w/ small changes
I'm submitting.

- S.P.


diff -Nru ../linus-2.6/net/sched/sch_api.c sch_api.c
--- ../linus-2.6/net/sched/sch_api.c    2004-09-02
14:47:49.000000000 -0700
+++ sch_api.c   2004-09-13 14:53:30.726090760 -0700
@@ -78,7 +78,7 @@
    checks and part of work, which is common to all
qdiscs
    and to provide rtnetlink notifications.

-   All real intelligent work is done inside qdisc
modules.
+   All real intelligent work is done inside each
qdisc modules.



@@ -87,29 +87,29 @@
    ---dequeue

    dequeue usually returns a skb to send. It is
allowed to return NULL,
-   but it does not mean that queue is empty, it just
means that
-   discipline does not want to send anything this
time.
+   but it does not mean the queue is empty; it means
that
+   the discipline does not want to send anything this
time.
    Queue is really empty if q->q.qlen == 0.
-   For complicated disciplines with multiple queues
q->q is not
-   real packet queue, but however q->q.qlen must be
valid.
+   For complicated disciplines with multiple queues,
q->q is not
+   real packet queue whereas q->q.qlen must be valid.

    ---enqueue

-   enqueue returns 0, if packet was enqueued
successfully.
-   If packet (this one or another one) was dropped,
it returns
-   not zero error code.
+   enqueue returns 0, if packet enqueues
successfully.
+   If packet (this one or another one) is dropped, it
returns
+   non-zero error code.
    NET_XMIT_DROP       - this packet dropped
-     Expected action: do not backoff, but wait until
queue will clear.
-   NET_XMIT_CN         - probably this packet
enqueued, but another one dropped.
-     Expected action: backoff or ignore
-   NET_XMIT_POLICED    - dropped by police.
-     Expected action: backoff or error to real-time
apps.
+     Expected action: do not back-off, but wait until
queue clears.
+   NET_XMIT_CN         - probably this packet is
enqueued, but another packet isdropped.
+     Expected action: back-off or ignore
+   NET_XMIT_POLICED    - packet is dropped by police.
+     Expected action: back-off or error to real-time
apps.

    Auxiliary routines:

    ---requeue

-   requeues once dequeued packet. It is used for
non-standard or
+   requeues once packet is dequeued. It is used for
non-standard or
    just buggy devices, which can defer output even if
dev->tbusy=0.

    ---reset



	
		
__________________________________
Do you Yahoo!?
New and Improved Yahoo! Mail - 100MB free storage!
http://promotions.yahoo.com/new_mail 
