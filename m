From: Erik Mckee <emckee@cs.tamu.edu>
Subject: Re: Fw: Divide Error in tcp_set_skb_tso_segs
Date: Mon, 22 Nov 2004 02:09:55 -0600 (CST)
Message-ID: <Pine.GSO.4.58.0411220209110.29499@unix.cs.tamu.edu>
References: <E1CW8VH-0006wt-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CW8VH-0006wt-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is 2.6.10-rc1, I am sorry for the double typo.  Should I try to
upgrade to 2.6.10-rc2 first?

Erik

On Mon, 22 Nov 2004, Herbert Xu wrote:

> Andrew Morton <akpm@osdl.org> wrote:
> >
> > I am running 2.4.10-rc2 and I have now gotten two instances of the above
> > oops.  I haven't managed to record the oops message for it as of yet.  I
> > am connecting to the internet over ppp.  IIRC, it has appeared both times
> > after ssh-ing to my email provider and running pine.  I'm not sure if this
> > had anything to do with it or not.  I rembmer that there are some do_IRQ
> > and do_softirq stuff in the traceback, along with something like a line of
> > ========='s....  This is with a non tainted kernel, compiled with GCC 3.4
> > with PREEMPT turned on...
>
> Please show us the backtrace so that we know where the zero mss is
> coming from.
>
> Thanks,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
