From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Sun, 14 May 2017 07:58:48 +0200
Message-ID: <20170514055848.GA23149@lst.de>
References: <20170510072627.12060-1-hch@lst.de> <1494514662.2489.1.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1494514662.2489.1.camel-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

this patch has not been superceeded by anything, can you explain why it
has been marked as such in patchworks?

On Thu, May 11, 2017 at 02:57:43PM +0000, Bart Van Assche wrote:
> On Wed, 2017-05-10 at 09:26 +0200, Christoph Hellwig wrote:
> > The driver has a lot of quality issues due to the lack of RDMA-side
> > review, and explicitly bypasses APIs to register all memory once a
> > connection is made, and thus allows remote access to memoery.
> > 
> > Mark it as broken until at least that part is fixed.
> 
> Since this is the only way to get the BROKEN marker in the v4.11 stable
> kernel series:
> 
> Acked-by: Bart Van Assche <bart.vanassche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>---end quoted text---
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
