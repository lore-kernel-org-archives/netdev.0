From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH v2 00/15] make structure field, function arguments and
 structures const
Date: Tue, 17 Oct 2017 12:23:50 +0200
Message-ID: <20171017102350.GA25786@kroah.com>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
 <20171017101245.GA4646@kroah.com>
 <alpine.DEB.2.20.1710171216060.5035@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org,
        lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, knaack.h-Mmb7MZpHnFY@public.gmane.org, lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org,
        pmeerw-jW+XmwGofnusTnJN9+BGXg@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hch-jcswGhMUV9g@public.gmane.org, sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org,
        kishon-l0cyMroinI0@public.gmane.org, bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org,
        balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org,
        jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        mfasheh-rOS7oXVqrJRBDgjK7y7TUQ@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-iio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        ocfs2-
To: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
Return-path: <linux-iio-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1710171216060.5035@hadrien>
Sender: linux-iio-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2017 at 12:16:18PM +0200, Julia Lawall wrote:
> 
> 
> On Tue, 17 Oct 2017, Greg KH wrote:
> 
> > On Mon, Oct 16, 2017 at 05:18:39PM +0200, Bhumika Goyal wrote:
> > > Make the ci_type field and some function arguments as const. After this
> > > change, make config_item_type structures as const.
> > >
> > > * Changes in v2- Combine all the followup patches and the constification
> > > patches into a series.
> >
> > Who do you want to take these patches?  If you want, I can take them
> > through my driver-core tree, which has done other configfs stuff like
> > this in the past.
> 
> Christoph Hellwig proposed to take care of it.

Great!  I'll go ack the individual ones that I might need to...

thanks,

greg k-h
