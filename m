From: Anton Blanchard <anton@samba.org>
Subject: KERNEL: assertion (!sk->sk_forward_alloc)
Date: Tue, 30 Nov 2004 08:18:57 +1100
Message-ID: <20041129211855.GC17540@krispykreme.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

I was running a network test on a machine with a number of e1000s in it
(netperf TCP_RR). The test included a range of message sizes from 64B
up to 64kB. The kernel is 2.6.10-rc2 BK from November 22.

I set tcp_tso_win_divisor to 2:

# cat /proc/sys/net/ipv4/tcp_tso_win_divisor
2

After a while some network assertion errors appeared in the log:

KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (180)

Note that this test was run using the send-to-self patch.

Anton
