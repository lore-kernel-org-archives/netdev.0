From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Tue, 11 Oct 2016 12:30:19 -0600
Message-ID: <20161011183019.GC20253@obsidianresearch.com>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
 <20161011173216.GA16892@obsidianresearch.com>
 <22f61258-9bcf-0adc-f23f-79a4f1d50c6a@redhat.com>
 <20161011180119.GB17319@obsidianresearch.com>
 <1476209407.448.9.camel@redhat.com>
 <073e0007-a43b-134d-ba7e-b290304be585@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <073e0007-a43b-134d-ba7e-b290304be585-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 11, 2016 at 02:17:51PM -0400, Doug Ledford wrote:

> Well, not exactly.  Even if we put 65520 into the scripts, the kernel
> will silently drop it down to 65504.  It actually won't require anyone
> change anything, they just won't get the full value.  I experimented
> with this in the past for other reasons and an overly large MTU setting
> just resulted in the max MTU.  I don't know if that's changed, but if it
> still works that way, this is much less of an issue than it might
> otherwise be.

So it is just docs and relying on PMTU? That is not as bad..

Still would be nice to avoid if at all possible..

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
