From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH 2/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Thu, 22 Mar 2012 16:45:43 -0700
Message-ID: <CAL1RGDU13hB5sYoEnsG5VcY2uH53WzWpGwAfkbi_moBfqb84HA@mail.gmail.com>
References: <CAL1RGDVxCE--P78bk0Me5o+ekSzgBYG0UJT6y3O7cK3mUGBjuQ@mail.gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6EB4@saturn3.aculab.com>
 <88B766C272F2C64B944B21AD078333151C964A66EF@EXMAIL.ad.emulex.com>
 <20120322205824.GC9614@obsidianresearch.com> <88B766C272F2C64B944B21AD078333151C964A670B@EXMAIL.ad.emulex.com>
 <3ae9829d-f8dd-4268-918a-94616eff0915@exht1.ad.emulex.com> <20120322224429.GA12980@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Parav.Pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org, David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120322224429.GA12980-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2012 at 3:44 PM, Jason Gunthorpe
<jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
> For hardware facing structures I'd combine this with a static assert
> to verify structure size at compile time.
>
> So..
>
> 1) Avoid using attributes unless the structure has unaligned members.
> 2) Avoid creating structures with unaligned members (eg for userspace
> =A0 communication)
> 3) Frown at hardware/firmware developers who make communication
> =A0 structures with unaligned members :)
> 4) Be explicit about padding in your layout for 64/32
> =A0 compatibility.

Excellent summary, thanks Jason.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
