From: "Tung, Chien Tin" <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH rdma-next 13/19] RDMA/netlink: Add netlink device
 definitions to UAPI
Date: Wed, 21 Jun 2017 16:18:54 +0000
Message-ID: <748B799B6A00724488C603FD7E5E7EB976FA5C5C@FMSMSX114.amr.corp.intel.com>
References: <20170621060528.3752-1-leon@kernel.org>
 <20170621060528.3752-14-leon@kernel.org>
 <20170621161149.GB10200@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170621161149.GB10200-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Jason Gunthorpe [mailto:jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org]
> Sent: Wednesday, June 21, 2017 11:12 AM
> To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Tung,
> Chien Tin <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; Steve Wise
> <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>; Stephen Hemminger
> <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>; Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>; Ariel Almog
> <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>; Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; Leon
> Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Subject: Re: [PATCH rdma-next 13/19] RDMA/netlink: Add netlink device
> definitions to UAPI
> 
> On Wed, Jun 21, 2017 at 09:05:22AM +0300, Leon Romanovsky wrote:
> >  	RDMA_NL_IWCM,
> >  	RDMA_NL_RSVD,
> >  	RDMA_NL_LS,	/* RDMA Local Services */
> > +	/*
> > +	 * RDMA_NL_I40IW not in use and it was added here by mistake,
> > +	 * but we need to keep it anyway, because it is UAPI and for
> > +	 * unknown reasons, someone in the field decided to replace "5"
> > +	 * with this define.
> > +	 */
> >  	RDMA_NL_I40IW,
> 
> Since this doesn't do anything, never did anything, I think you should just
> delete it. Anything in userspace that refers to this name is unconditionally
> broken and a compile failure is the better choice.
> 
> Jason

I agree.  Please delete RDMA_NL_I40IW.

Chien
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
