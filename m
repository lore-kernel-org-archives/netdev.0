From: <Parav.Pandit-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH 2/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Thu, 22 Mar 2012 14:10:35 -0700
Message-ID: <88B766C272F2C64B944B21AD078333151C964A670B@EXMAIL.ad.emulex.com>
References: <CAL1RGDVxCE--P78bk0Me5o+ekSzgBYG0UJT6y3O7cK3mUGBjuQ@mail.gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6EB4@saturn3.aculab.com>
 <88B766C272F2C64B944B21AD078333151C964A66EF@EXMAIL.ad.emulex.com>
 <20120322205824.GC9614@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>, <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120322205824.GC9614-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Jason Gunthorpe [mailto:jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org]
> Sent: Friday, March 23, 2012 2:28 AM
> To: Pandit, Parav
> Cc: David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org; roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org; linux-
> rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [PATCH 2/9] ocrdma: Driver for Emulex OneConnect RDMA
> adapter
> 
> On Thu, Mar 22, 2012 at 01:52:30PM -0700, Parav.Pandit-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org
> wrote:
> 
> > > This can be used to force 32bit alignment in amd64 code in order to
> > > match definitions in 32bit userspace.
> > > For new things it would make sense to force 64bit alignment of 64bit
> > > fields for 32bit code.
> >
> > o.k. so I'll use aligned attribute to align user-kernel interface data
> > structure to 8 byte boundary.  That should work for 32-bit and 64-bit
> > user and kernel space and does't hurt performance either?
> 
> If the structure is only for user/kernel interfacing then it is much better to
> add explicit padding fields to naturally place 64 bit quantities on an 8 byte
> alignment than to mess with gcc specific attributes (user space has a much
> wide choice of compilers).
> 
> This was David's second suggestion. Better to do this now before the driver is
> accepted :)
> 
o.k. I'll align them to naturally 8 byte boundary. 

> Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
