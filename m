From: Stefano Stabellini <sstabellini@kernel.org>
Subject: Re: [PATCH] xen/9pfs: select CONFIG_XEN_XENBUS_FRONTEND
Date: Wed, 19 Apr 2017 16:10:29 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1704191609300.31486@sstabellini-ThinkPad-X260>
References: <20170419170648.3041204-1-arnd@arndb.de> <alpine.DEB.2.10.1704191020310.31486@sstabellini-ThinkPad-X260>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Arnd Bergmann <arnd@arndb.de>,
        Stefano Stabellini <stefano@aporeto.com>,
        boris.ostrovsky@oracle.com, groug@kaod.org,
        xen-devel@lists.xenproject.org,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        "David S. Miller" <davem@davemloft.net>,
        v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: jgross@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1704191020310.31486@sstabellini-ThinkPad-X260>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Juergen, I have committed this patch to for-linus-4.12 and linux-next, I
hope that's OK.

Og Wed, 19 Apr 2017, Stefano Stabellini wrote:
> On Wed, 19 Apr 2017, Arnd Bergmann wrote:
> > All Xen frontends need to select this symbol to avoid a link error:
> > 
> > net/built-in.o: In function `p9_trans_xen_init':
> > :(.text+0x149e9c): undefined reference to `__xenbus_register_frontend'
> > 
> > Fixes: d4b40a02f837 ("xen/9pfs: build 9pfs Xen transport driver")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> Thank you for the fix!
> 
> Reviewed-by: Stefano Stabellini <sstabellini@kernel.org>
> > ---
> >  net/9p/Kconfig | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/net/9p/Kconfig b/net/9p/Kconfig
> > index 3f286f1bd1d3..e6014e0e51f7 100644
> > --- a/net/9p/Kconfig
> > +++ b/net/9p/Kconfig
> > @@ -24,6 +24,7 @@ config NET_9P_VIRTIO
> >  
> >  config NET_9P_XEN
> >  	depends on XEN
> > +	select XEN_XENBUS_FRONTEND
> >  	tristate "9P Xen Transport"
> >  	help
> >  	  This builds support for a transport for 9pfs between
> > -- 
> > 2.9.0
> > 
> 
