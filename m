From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] SLAB_PANIC cleanup
Date: Tue, 17 Aug 2004 15:07:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040817150739.A22153@infradead.org>
References: <20040817100755.A20489@infradead.org> <Xine.LNX.4.44.0408170933240.9207-100000@dhcp83-76.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0408170933240.9207-100000@dhcp83-76.boston.redhat.com>; from jmorris@redhat.com on Tue, Aug 17, 2004 at 09:38:16AM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 17, 2004 at 09:38:16AM -0400, James Morris wrote:
> Yes, although I'm not clear on what should be done.  Returning an error
> via an initcall does not do anything, so if these were built statically,
> then the kernel would go on running after they failed.  This is a general
> problem.  e.g. IPv6, which is commonly built as a module, will panic if
> kmem_cache_create() fails during module load in several places.

The ipv6 behaviour is definnitly bad.  OOM situations shouldn't panic
the kernel.

If something is can be built modular it surely isn't important enough to
panic the kernel on bootup if it can't initialize - after all people can
run a kernel without the module loaded just fine.
