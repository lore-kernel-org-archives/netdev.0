From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] SLAB_PANIC cleanup
Date: Wed, 18 Aug 2004 01:24:05 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040818042404.GB1007@conectiva.com.br>
References: <Xine.LNX.4.44.0408170237020.7736-100000@dhcp83-76.boston.redhat.com> <20040817.155942.51047516.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@redhat.com, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040817.155942.51047516.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Tue, Aug 17, 2004 at 03:59:42PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ escreveu:
> In article <Xine.LNX.4.44.0408170237020.7736-100000@dhcp83-76.boston.redhat.com> (at Tue, 17 Aug 2004 02:43:38 -0400 (EDT)), James Morris <jmorris@redhat.com> says:
> 
> It generally seems okay. Just a few things for readability.
> 
> > diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/core/neighbour.c linux-2.6.8.1-mm1.w/net/core/neighbour.c
> > --- linux-2.6.8.1-mm1.o/net/core/neighbour.c	2004-06-16 01:18:56.000000000 -0400
> > +++ linux-2.6.8.1-mm1.w/net/core/neighbour.c	2004-08-17 02:57:22.888296160 -0400
> > @@ -1165,12 +1165,9 @@
> >  	if (!tbl->kmem_cachep)
> >  		tbl->kmem_cachep = kmem_cache_create(tbl->id,
> >  						     tbl->entry_size,
> > -						     0, SLAB_HWCACHE_ALIGN,
> > +						     0, SLAB_HWCACHE_ALIGN|
> > +						     SLAB_PANIC,
> 
> I rather prefer
> 						     tbl->entry_size, 0,
> 						     SLAB_HWCACHE_ALIGN|SLAB_PANIC,

I rather prefer:

                                                     SLAB_HWCACHE_ALIGN | SLAB_PANIC,

Regards,

- Arnaldo
