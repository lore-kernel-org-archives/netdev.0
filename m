From: Olivier Galibert <galibert@pobox.com>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Tue, 30 Sep 2003 14:06:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930120622.GA24747@dspnet.fr.eu.org>
References: <20030928225941.GW15338@fs.tum.de> <20030928231842.GE1039@conectiva.com.br> <20030928232403.GX15338@fs.tum.de> <20030929220916.19c9c90d.davem@redhat.com> <1064903562.6154.160.camel@imladris.demon.co.uk> <20030930000302.3e1bf8bb.davem@redhat.com> <1064907572.21551.31.camel@hades.cambridge.redhat.com> <20030930010855.095c2c35.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>, bunk@fs.tum.de,
        acme@conectiva.com.br, netdev@oss.sgi.com, pekkas@netcore.fi,
        lksctp-developers@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030930010855.095c2c35.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 30, 2003 at 01:08:55AM -0700, David S. Miller wrote:
> On Tue, 30 Sep 2003 08:39:33 +0100
> David Woodhouse <dwmw2@infradead.org> wrote:
> > 99% or more of tristate options can be enabled without affecting the
> > kernel, and it is expected that such options can be set to 'm' later,
> > while the kernel in question is actually running, then built and loaded
> > without a reboot.
> 
> Expected by whom?  Not by me.

By me for instance.  I'm used to modules having no influence until
loaded, even at compilation time.  I'm used to in-tree and out-of-tree
modules to have exactly the same status (ignoring the binary-only
modules crap).


> > We should strive to keep this true.
> 
> For things _OUTSIDE_ the kernel, surely.  But inside the kernel
> tree I don't see any value in this new restriction.
> 
> > 	Allow this kernel to ever support IPv6? Y/N
> > 	Build IPv6 support? Y/M/N
> 
> And I still think this is a complete joke.

I suspect what you _really_ want is a "disable ipv6 entirely"
depending on CONFIG_EMBEDDED which would remove the then bloat.
Normal users would never see it and the meaning would be obvious for
the ones who care.

  OG.
