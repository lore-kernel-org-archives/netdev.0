From: Andrew Morton <akpm@osdl.org>
Subject: Fw: Divide Error in tcp_set_skb_tso_segs
Date: Sun, 21 Nov 2004 22:41:01 -0800
Message-ID: <20041121224101.17e7fd95.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Erik Mckee <emckee@cs.tamu.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 22 Nov 2004 00:28:07 -0600 (CST)
From: Erik Mckee <emckee@cs.tamu.edu>
To: linux-kernel@vger.kernel.org
Subject: Divide Error in tcp_set_skb_tso_segs


Hello!

I am running 2.4.10-rc2 and I have now gotten two instances of the above
oops.  I haven't managed to record the oops message for it as of yet.  I
am connecting to the internet over ppp.  IIRC, it has appeared both times
after ssh-ing to my email provider and running pine.  I'm not sure if this
had anything to do with it or not.  I rembmer that there are some do_IRQ
and do_softirq stuff in the traceback, along with something like a line of
========='s....  This is with a non tainted kernel, compiled with GCC 3.4
with PREEMPT turned on...

I can try to collect more information if it is desired....I am not on the
list, so please CC me with any replies...

TIA
Erik
