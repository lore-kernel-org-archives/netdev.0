From: Anton Blanchard <anton@samba.org>
Subject: Re: KERNEL: assertion (!sk->sk_forward_alloc)
Date: Sun, 5 Dec 2004 18:46:58 +1100
Message-ID: <20041205074658.GA19168@krispykreme.ozlabs.ibm.com>
References: <20041129211855.GC17540@krispykreme.ozlabs.ibm.com> <20041129172210.687bcad3.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041129172210.687bcad3.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
Hi Dave,

> Try to reproduce without that patch installed.
> 
> If there is any mixup of SKB handling by any element in the
> path the packet travels, you're screw up all the TCP
> accounting knobs on the socket and easily trigger messages
> like the above.

I'll try. FYI we have 70 gigabit cards in that machine, the reason
send-to-self is so useful is that we only need one expensive machine.
Without the patch we need to find two expensive machines with 35
gigabits in each :)

Anton
