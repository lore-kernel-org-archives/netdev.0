From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: Divide Error in tcp_set_skb_tso_segs
Date: Mon, 22 Nov 2004 18:20:51 +1100
Message-ID: <E1CW8VH-0006wt-00@gondolin.me.apana.org.au>
References: <20041121224101.17e7fd95.akpm@osdl.org>
Cc: netdev@oss.sgi.com, emckee@cs.tamu.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20041121224101.17e7fd95.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> 
> I am running 2.4.10-rc2 and I have now gotten two instances of the above
> oops.  I haven't managed to record the oops message for it as of yet.  I
> am connecting to the internet over ppp.  IIRC, it has appeared both times
> after ssh-ing to my email provider and running pine.  I'm not sure if this
> had anything to do with it or not.  I rembmer that there are some do_IRQ
> and do_softirq stuff in the traceback, along with something like a line of
> ========='s....  This is with a non tainted kernel, compiled with GCC 3.4
> with PREEMPT turned on...

Please show us the backtrace so that we know where the zero mss is
coming from.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
