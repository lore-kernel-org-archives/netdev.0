From: N N Ashok <nalkunda@egr.msu.edu>
Subject: Resend: current bandwidth measurement
Date: Sat, 24 May 2003 19:25:38 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200305241925.38061.nalkunda@egr.msu.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Seems like my first mail didnt show up on the list.

Hi,
   I wanted to know how the current flow rate for an interface is maintained
in the kernel. I studied the tc_stats structure (include/linux/pkt_sched.h)
but its bps and pps fields are not used anywhere except in net/sched/police.c
(used "stats.bps" to search for the files).
   Is it that the current bps and pps are maintained in the queue structures?
If so, can you point me to the relevant files/structures/functions.

Thanks in advance,
Ashok
