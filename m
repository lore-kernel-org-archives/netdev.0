From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Tue, 11 Oct 2016 11:42:24 -0600
Message-ID: <20161011174224.GA17319@obsidianresearch.com>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
 <20161011173216.GA16892@obsidianresearch.com>
 <1476207452.448.2.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1476207452.448.2.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 11, 2016 at 07:37:32PM +0200, Paolo Abeni wrote:
> On Tue, 2016-10-11 at 11:32 -0600, Jason Gunthorpe wrote:
> > On Tue, Oct 11, 2016 at 07:15:44PM +0200, Paolo Abeni wrote:
> > 
> > > Also the connected mode maximum mtu is reduced by 16 bytes to
> > > cope with the increased hard header len.
> > 
> > Changing the MTU is going to cause annoying interop problems, can you
> > avoid this?
> 
> I don't like changing the maximum MTU value, too, but I was unable to
> find an alternative solution. The PMTU detection should protect against
> such issues.

It is more that PMTU, we have instructed all users that is the MTU
number needed to enable CM mode, so it appears in documentation,
scripts, etc.

There is really no way to re-use some of the existing alignment
padding or exceed 64k?

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
