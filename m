From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: Netlink messages without NLM_F_REQUEST flag
Date: Wed, 7 Jun 2017 20:00:37 +0300
Message-ID: <20170607170037.GG1127@mtr-leonro.local>
References: <20170607161901.GD1127@mtr-leonro.local>
 <20170607163758.GA25313@obsidianresearch.com>
 <CALq1K=Jj_jJ5_OAiiws-es37tFEsLeLJeSvnU+bfwd0KLkGM3Q@mail.gmail.com>
 <20170607164750.GA7507@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="YH9Qf6Fh2G5kB/85"
Cc: Kaike Wan <kaike.wan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, John Fleck <john.fleck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        RDMA mailing list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170607164750.GA7507-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--YH9Qf6Fh2G5kB/85
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 07, 2017 at 10:47:50AM -0600, Jason Gunthorpe wrote:
> On Wed, Jun 07, 2017 at 07:43:44PM +0300, Leon Romanovsky wrote:
> > On Wed, Jun 7, 2017 at 7:37 PM, Jason Gunthorpe
> > <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
> > > On Wed, Jun 07, 2017 at 07:19:01PM +0300, Leon Romanovsky wrote:
> > >> It makes me wonder if it is expected behavior for
> > >> ibnl_rcv_reply_skb() to handle !NLM_F_REQUEST messages and do we
> > >> really need it? What are the scenarios?  In my use case, which is
> > >> for sure different from yours, I'm always setting NLM_F_REQUEST
> > >> while communicating with kernel.
> > >
> > > If I recall the user space SA code issues REQUESTS from the kernel to
> > > userspace, so userspace returns with the response format. This is
> > > abnormal for netlink hence the special function.
> >
> > In netlink semantics, kernel side is supposed to send netlink
> > notification message and userspace is supposed to send REQUEST.
>
> That pattern is for async communications, the SA stuff needs a sync
> protocol, unfortunately.

There is special flag NLM_F_ACK for it and userspace will set
NLM_F_REQUEST | NLM_F_ACK once synchronization is needed.

>
> Jason

--YH9Qf6Fh2G5kB/85
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlk4MTUACgkQ5GN7iDZy
WKf/PQ//TuTB8yVW1rT8ya0bcJBhuJpuaLR7LJWuWi6S1FKisuhBE53zK5mVlGiJ
Lmga4nxAfJuCk+8OpXPaDspbq68ZazZI2/Mn4DHBxTgG5jKokCuWERxUr+WDokMK
wq5I1Om7JCiRaXNbGURZnkLZ+lGlI/Qv/UbhZpNEYFHSNsblt6HuqnoDyCFmF5bQ
egohnb/tCqSHP1aufhQjy3R+ghlwk1nAIqbKG/eOaNc7HFeLxXYAut0lOSuTun1t
df3GQ5X/3qyB6nLPb/CqEtyWff1/z7ChVTPc+Fl57EzyKGm1rOySSW3nZC8rRpNK
MGNj60FAhN9wwluojrgjlKRUe0aDiQcvs34yLirke1WcxNkcKLttSVW/dN0s37Om
+JqpR2fq3XiSJRS+3OgIdxYYPfNqTnwkEWE1jyVk0PB7mQmIxlrLGKmzZ9iXHkiU
o3YF7g6ANs3+7zSTz8wWMJuyFFnasC01FlJQ7U3D12tf++fVJSAvDQ3tDjSjeTz5
V8SFH9yoNsFWomxRnJYo+UmVNNuXgFMFbt12SWfXOutPieLKcDBau5RVwhiRbJOF
gQK7fIyQSwph3reThy9fwEEdWwX2fQo8+pNHo4b8v+B7HBSO0oFnC4QRglcRRWEl
NMbeUzvkSZIy9ivFPOHNZpr23nA/OMQARTsNo3HES8ibOuUGlMo=
=d3N2
-----END PGP SIGNATURE-----

--YH9Qf6Fh2G5kB/85--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
