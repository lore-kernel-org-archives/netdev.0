From: "David S. Miller" <davem@davemloft.net>
Subject: Re: KERNEL: assertion (!sk->sk_forward_alloc)
Date: Mon, 29 Nov 2004 17:22:10 -0800
Message-ID: <20041129172210.687bcad3.davem@davemloft.net>
References: <20041129211855.GC17540@krispykreme.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20041129211855.GC17540@krispykreme.ozlabs.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Nov 2004 08:18:57 +1100
Anton Blanchard <anton@samba.org> wrote:

> KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
> KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (180)
> 
> Note that this test was run using the send-to-self patch.

Try to reproduce without that patch installed.

If there is any mixup of SKB handling by any element in the
path the packet travels, you're screw up all the TCP
accounting knobs on the socket and easily trigger messages
like the above.
