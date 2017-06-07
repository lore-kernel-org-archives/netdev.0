From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: Netlink messages without NLM_F_REQUEST flag
Date: Wed, 7 Jun 2017 21:18:10 +0300
Message-ID: <20170607181810.GI1127@mtr-leonro.local>
References: <20170607161901.GD1127@mtr-leonro.local>
 <20170607163758.GA25313@obsidianresearch.com>
 <CALq1K=Jj_jJ5_OAiiws-es37tFEsLeLJeSvnU+bfwd0KLkGM3Q@mail.gmail.com>
 <20170607164750.GA7507@obsidianresearch.com>
 <20170607170037.GG1127@mtr-leonro.local>
 <20170607170702.GB7507@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="EdRE1UL8d3mMOE6m"
Cc: Kaike Wan <kaike.wan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, John Fleck <john.fleck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        RDMA mailing list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170607170702.GB7507-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--EdRE1UL8d3mMOE6m
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 07, 2017 at 11:07:02AM -0600, Jason Gunthorpe wrote:
> On Wed, Jun 07, 2017 at 08:00:37PM +0300, Leon Romanovsky wrote:
> > On Wed, Jun 07, 2017 at 10:47:50AM -0600, Jason Gunthorpe wrote:
> > > On Wed, Jun 07, 2017 at 07:43:44PM +0300, Leon Romanovsky wrote:
> > > > On Wed, Jun 7, 2017 at 7:37 PM, Jason Gunthorpe
> > > > <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
> > > > > On Wed, Jun 07, 2017 at 07:19:01PM +0300, Leon Romanovsky wrote:
> > > > >> It makes me wonder if it is expected behavior for
> > > > >> ibnl_rcv_reply_skb() to handle !NLM_F_REQUEST messages and do we
> > > > >> really need it? What are the scenarios?  In my use case, which is
> > > > >> for sure different from yours, I'm always setting NLM_F_REQUEST
> > > > >> while communicating with kernel.
> > > > >
> > > > > If I recall the user space SA code issues REQUESTS from the kernel to
> > > > > userspace, so userspace returns with the response format. This is
> > > > > abnormal for netlink hence the special function.
> > > >
> > > > In netlink semantics, kernel side is supposed to send netlink
> > > > notification message and userspace is supposed to send REQUEST.
> > >
> > > That pattern is for async communications, the SA stuff needs a sync
> > > protocol, unfortunately.
> >
> > There is special flag NLM_F_ACK for it and userspace will set
> > NLM_F_REQUEST | NLM_F_ACK once synchronization is needed.
>
> AFAIK, that is different, that is acking and retriggering a single shot
> notification, not completing a kernel initiated handshake.

It is acking that message from user was received by kernel and now
processing. The message from kernel to user are anyway unreliable [1],
so I don't understand on which handshake you are talking.

[1] "reliable transmissions from kernel to user are impossible in any case"
https://linux.die.net/man/7/netlink

>
> Jason

--EdRE1UL8d3mMOE6m
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlk4Q2IACgkQ5GN7iDZy
WKfiCBAAv6xbdu/QPw1GfotP8Iob3O1HTPqWxIP9/Vh8oeY6a0pyHFlkKlv6jU97
N5DWnkk8GU5ZpxrEsf69WhD0t0G1+GPrUAb7NQAHsi2hlbRODadXeds8fIfgFRRp
CUwzIja2dRrSaXzOwcWmFevhCgbs88+TTTcPv6BirTcw8rJrZ973OnixSdHIyy0x
BbG/O9Xhq6tn2PFOIoj1HeXlt+9aBm12fON5FTW6nn6sVIFTomdX5DImlrfEaghS
N98EAvidm7yxIl3NrkuvvXu/c4Z7toYXbd1TKGkC03kE8Wt4W8tZzgQDL8rObRyH
JyYosO3QexRr9i8EIkGvfyb6nlzc6jRuEIwa0xPfqZp+agKmCtm0kvqL1lSze70K
HJmkKMv8P0DloFRZksS1+SgFsZmSczlITWxeV86jY+Jwjkbh+jww47sXpSrbGXvt
zZBhTkgyDYTXVlFOA2CBwzx55Vl/JuQbILe26nooP63Q3F0P0GLUMAlgP0JhQ+vw
3SpcLHsvGYwvmJOtBV4oKQZ89i8grlIPh3xpeVTndqoQmTGC/YwCb31lrNJK3ov0
l7hTVl2zZrXKSzg5SO4yK44guyH6QKsBC2mqAaeQhXoMVeM56oszu6TNsGvpLPDv
p0gqRGZKy6z4v7wn4WHh8lQRcmdA0JzptaxdCh9F74JhRMwAcq4=
=7EUZ
-----END PGP SIGNATURE-----

--EdRE1UL8d3mMOE6m--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
