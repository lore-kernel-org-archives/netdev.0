From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Tue, 30 Sep 2003 11:57:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930095721.GA1036@mars.ravnborg.org>
References: <1064903562.6154.160.camel@imladris.demon.co.uk> <20030930000302.3e1bf8bb.davem@redhat.com> <1064907572.21551.31.camel@hades.cambridge.redhat.com> <20030930010855.095c2c35.davem@redhat.com> <1064910398.21551.41.camel@hades.cambridge.redhat.com> <20030930013025.697c786e.davem@redhat.com> <1064911360.21551.49.camel@hades.cambridge.redhat.com> <20030930015125.5de36d97.davem@redhat.com> <1064913241.21551.69.camel@hades.cambridge.redhat.com> <20030930022410.08c5649c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>, bunk@fs.tum.de,
        acme@conectiva.com.br, netdev@oss.sgi.com, pekkas@netcore.fi,
        lksctp-developers@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030930022410.08c5649c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 30, 2003 at 02:24:10AM -0700, David S. Miller wrote:
> 
> > In the 2.6 kernel, I suspect that these same version strings are now
> > produced as a side-effect of the 'make vmlinux' stage, and hence that
> > it's required to 'make vmlinux' before any modules can be built.
> 
> What this means is that it's required for the kernel image to be up to
> date before any modules can be built.  If we can check that in the
> build system for the sake of modversions (and if we're not doing that
> now it's a bug we should fix) we can do it equally for ipv6.

There is a postprocessing step when building modules that take care
of modversioning. And yes, it requires a final vmlinux.

	Sam
