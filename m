From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] SLAB_PANIC cleanup
Date: Wed, 18 Aug 2004 01:28:00 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040818042800.GC1007@conectiva.com.br>
References: <20040817100755.A20489@infradead.org> <Xine.LNX.4.44.0408170933240.9207-100000@dhcp83-76.boston.redhat.com> <20040817150739.A22153@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@redhat.com>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20040817150739.A22153@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Tue, Aug 17, 2004 at 03:07:39PM +0100, Christoph Hellwig escreveu:
> On Tue, Aug 17, 2004 at 09:38:16AM -0400, James Morris wrote:
> > Yes, although I'm not clear on what should be done.  Returning an error
> > via an initcall does not do anything, so if these were built statically,
> > then the kernel would go on running after they failed.  This is a general
> > problem.  e.g. IPv6, which is commonly built as a module, will panic if
> > kmem_cache_create() fails during module load in several places.
> 
> The ipv6 behaviour is definnitly bad.  OOM situations shouldn't panic
> the kernel.
> 
> If something is can be built modular it surely isn't important enough to
> panic the kernel on bootup if it can't initialize - after all people can
> run a kernel without the module loaded just fine.

Agreed, not because it is "not important", but because panicing at module
load, even in very rare cases is unnacceptable IMHO.

- Arnaldo
