From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Assertions when lowering tcp_tso_win_divisor
Date: Tue, 16 Nov 2004 09:47:14 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0411160931080.31882@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

We are seeing following assertions when running specweb99 with
tcp_tso_win_divisor lowered to 4, 2 or 1 on linux 2.6.9 based kernels.

KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (152)

looks like an issue with the accounting of sk_forward_alloc with non-default
values of tcp_tso_win_divisor.

Thanks
Sridhar
