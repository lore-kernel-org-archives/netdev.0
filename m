From: Bjorn Helgaas <helgaas-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v4 01/16] vmxnet3: Move PCI Id to pci_ids.h
Date: Tue, 20 Sep 2016 08:37:41 -0500
Message-ID: <20160920133741.GC13855@localhost>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-2-git-send-email-aditr@vmware.com>
 <20160914110854.GA15800@yuval-lap.uk.oracle.com>
 <DM2PR0501MB844852987661859C6654E40C5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
 <20160914162452.GA3216@yuval-lap.Home>
 <DM2PR0501MB84422A1029EE72FC727F960C5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        pv-drivers <pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Jorgen S. Hansen" <jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        Aditya Sarwade <asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        George Zhang <georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        Bryan Tan <bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
To: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <DM2PR0501MB84422A1029EE72FC727F960C5F10-SXUgMXdxDSdudfUQJyYm35LWcSx1hRipwIZJ9u9yWa8oOQlpcoRfSA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 07:36:34PM +0000, Adit Ranadive wrote:
> On Wed, Sep 14, 2016 at 09:25:18 -0700, Yuval Shaia wrote:
> > On Wed, Sep 14, 2016 at 04:00:25PM +0000, Adit Ranadive wrote:
> > > On Wed, Sep 14, 2016 at 04:09:12 -0700, Yuval Shaia wrote:
> > > > Please update vmxnet3_drv.c accordingly.
> > >
> > > Any reason why? I don't think we need to. Vmxnet3 should just pick up
> > > the moved PCI device id from pci_ids.h file.
> > 
> > So now you need to include it from vmxnet3_drv.c.
> > Same with pvrdma_main.c
> 
> If you're asking me to include pci_ids.h in our drivers we already do that
> by including pci.h in both the drivers. 
> pci.h already includes pci_ids.h - 
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/include/linux/pci.h#n35
> 
> If that's going to change maybe someone from the PCI group can comment on.

I don't contemplate a change there.  It's fine to get pci_ids.h via pci.h.
Almost all drivers do that today.  If we do change it someday, we can
change this driver along with all the rest.

Bjorn
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
