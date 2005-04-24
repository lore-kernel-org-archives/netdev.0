From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: 2x crash in 2.6.12-rc2-mm3
Date: Sun, 24 Apr 2005 18:14:10 +1000
Message-ID: <E1DPcFm-0002KW-00@gondolin.me.apana.org.au>
References: <6.2.3.0.2.20050424125154.04124008@tornado.reub.net>
Cc: akpm@osdl.org, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: reuben-lkml@reub.net (Reuben Farrelly)
In-Reply-To: <6.2.3.0.2.20050424125154.04124008@tornado.reub.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Reuben Farrelly <reuben-lkml@reub.net> wrote:
> I also had this one last night (still with rc2-mm3) but hadn't yet 
> gotten around to sending it on...
> 
> BUG: soft lockup detected on CPU#1!
> 
> Pid: 0, comm:              swapper
> EIP: 0060:[<c03404f1>] CPU: 1
> EIP is at _spin_lock+0x52/0x63
>  EFLAGS: 00000202    Not tainted  (2.6.12-rc2-mm3)
> EAX: 00000001 EBX: d3454e24 ECX: d34550e8 EDX: 00000000
> ESI: dff92000 EDI: d3454e24 EBP: c030a9bd DS: 007b ES: 007b
> CR0: 8005003b CR2: b78ba004 CR3: 0c6b1000 CR4: 000006d0
>  [<c030a9cf>] tcp_delack_timer+0x12/0x1e3
>  [<c01246fe>] run_timer_softirq+0xd6/0x1a6

The only thing these two traces tell us is that there is probably
something seriously screwed up in mm with regards to timers and/or
spin locks.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
