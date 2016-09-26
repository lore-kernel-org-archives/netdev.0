From: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5 16/16] MAINTAINERS: Update for PVRDMA driver
Date: Sun, 25 Sep 2016 22:22:02 -0700
Message-ID: <7ddc5906-6ba8-335e-c0b8-eb60427a1be8@vmware.com>
References: <cover.1474759181.git.aditr@vmware.com>
 <fe5e7704757254073963cd40bff5240421b1fce0.1474759181.git.aditr@vmware.com>
 <20160925073010.GW4088@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        <asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, <georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        <bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160925073010.GW4088-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 25 2016 at 10:30:10AM +0300, Leon Romanovsky wrote:
> On Sat, Sep 24, 2016 at 04:21:40PM -0700, Adit Ranadive wrote:
> > Add maintainer info for the PVRDMA driver.
> >
> > Reviewed-by: Jorgen Hansen <jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> > Reviewed-by: George Zhang <georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> > Reviewed-by: Aditya Sarwade <asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> > Reviewed-by: Bryan Tan <bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> > Signed-off-by: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> > ---
> > Changes v4->v5:
> >  - Added pvrdma files to common UAPI folder.
> > ---
> >  MAINTAINERS | 9 +++++++++
> >  1 file changed, 9 insertions(+)
> >
> > diff --git a/MAINTAINERS b/MAINTAINERS
> > index 87e23cd..5023dc0 100644
> > --- a/MAINTAINERS
> > +++ b/MAINTAINERS
> > @@ -12615,6 +12615,15 @@ S:	Maintained
> >  F:	drivers/scsi/vmw_pvscsi.c
> >  F:	drivers/scsi/vmw_pvscsi.h
> >
> > +VMWARE PVRDMA DRIVER
> > +M:	Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> > +M:	VMware PV-Drivers <pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> > +L:	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > +S:	Maintained
> > +F:	drivers/infiniband/hw/pvrdma/
> > +F:	include/uapi/rdma/pvrdma-abi.h
> > +F:	include/uapi/rdma/pvrdma-uapi.h
> 
> Please remove the last two lines, these files will be maintained by
> Doug.
> 
> Thanks
>

Ok. Based on your recent patch series on export vendor specific ABIs,
the ABI files were added to be maintained [1] by individual driver owners. 
Is that not the case now?

[1] http://marc.info/?l=linux-rdma&m=147455473718235&w=2
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
