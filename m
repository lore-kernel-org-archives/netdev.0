From: David Brownell <david-b@pacbell.net>
Subject: assertion failure at net/sched/sch_generic.c(530)
Date: Tue, 23 Sep 2003 17:11:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F70E12A.1090204@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

After running some TTCP tests (unidirectional TTCP 9+ hours,
then bidirectional for about 8 hours more) over a network link,
I shut it down the usual way and got an unusual message.  I've
never seen this before; this is a recent 2.6.0-test5 BK snapshot
(a few days old):

   KERNEL: assertion (dev->qdisc_list == NULL) failed at
   net/sched/sch_generic.c(530)

Could someone please translate that for me -- trouble?

The interface was down at that point, and this was evidently
triggered by the unregister_netdev() that "rmmod" caused.

- Dave
