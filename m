From: John Heffner <jheffner@psc.edu>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 16:58:16 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0409291648560.3434-100000@dexter.psc.edu>
References: <20040929012757.5d0dff61.ak@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, <herbert@gondor.apana.org.au>,
        <niv@us.ibm.com>, <andy.grover@gmail.com>, <anton@samba.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040929012757.5d0dff61.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004, Andi Kleen wrote:

> I tried to re-test it but I didn't get very far because the kernel
> with your patch crashes regularly during netperf. No serial console,
> but the backtrace is {tcp_ack+877} {tcp_rcv_established+350} ...
> Before that there are a few "retrans out leaked" messages.

I just tried to re-create this situation, and I got the same problem.
Latest bk tree with dave's 5 patches, gcc 3.3.4, uni-processor p4/e1000 to
a slow-ish p3/sk98lin (dual-cpu but with maxcpus=1).

  -John
