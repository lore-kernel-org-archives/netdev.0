From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPsec and Path MTU
Date: Thu, 17 Jun 2004 15:22:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617152216.00a5cec9.davem@redhat.com>
References: <20040616202341.GD29781@ms2.inr.ac.ru>
	<E1BajZO-0001UK-00@gondolin.me.apana.org.au>
	<20040617105843.314dfe30.davem@redhat.com>
	<20040617213130.GB14089@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040617213130.GB14089@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Jun 2004 07:31:30 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Jun 17, 2004 at 10:58:43AM -0700, David S. Miller wrote:
> >
> > Do you see what xfrm_get_mss() does?  It calls into x->type->get_max_size()
> > and this is where ESP reports this kind of thing (re: block padding).
> 
> Yes I know.  But this is only used in TCP currently.

Right.  I'm sorry, is someone trying to do NFS/UDP over IPSEC?
My condolences.  :-)

More seriously, it is a fringe case.  We do need to handle it,
but it is no accident that there haven't been very
many folks complaining about it.
