From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Sun, 7 May 2017 09:33:29 +0300
Message-ID: <20170507063329.GL22833@mtr-leonro.local>
References: <20170504180216.7665-1-leon@kernel.org>
 <20170505085457.0029edc9@griffin>
 <20170505131754.GH22833@mtr-leonro.local>
 <20170506104826.GD2017@nanopsycho>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="JjNtGRvLZqzR8wa5"
Cc: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Ram Amrani <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170506104826.GD2017@nanopsycho>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--JjNtGRvLZqzR8wa5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, May 06, 2017 at 12:48:26PM +0200, Jiri Pirko wrote:
> Fri, May 05, 2017 at 03:17:54PM CEST, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org wrote:
> >On Fri, May 05, 2017 at 08:54:57AM +0200, Jiri Benc wrote:
> >> On Thu,  4 May 2017 21:02:08 +0300, Leon Romanovsky wrote:
> >> > In order to close object model, ensure reuse of existing code and make this
> >> > tool usable from day one, we decided to implement wrappers over legacy sysfs
> >> > prior to implementing netlink functionality. As a nice bonus, it will allow
> >> > to use this tool with old kernels too.
> >>
> >> This sounds wrong. We don't support legacy ioctl interface for the 'ip'
> >> command, either. I think rdma should be converted to netlink first and
> >> the new tool should only use netlink.
> >
> >RDMA in slightly different situation than "ip" tool was. "ip" was implemented
> >when tools like ifconfig existed. It allowed to old and new systems to be
> >configured to some degree. In RDMA community, there are no similar tools like
> >"ifconfig". Implementation in netlink-only interface will leave old systems without
> >common tool at all.
> >
> >As an upstream-oriented person, I personally fine with that, but anyway would
> >like to get wider agreement/disagreement on that, before removing sysfs
> >parsing logic from the rdmatool.
>
> I tend to agree with Jiri Benc. I fear that supporting sysfs + netlink
> api later on for the same things will make the code unnecessary complex.
> Also, the legacy sysfs will most likely stay there forever so there will
> be no actual motivation to port the existing things to the new netlink
> api.
>
> For the prototyping purposes, I belive that what you did makes perfect
> sense. But for the actual mergable version, my feeling is that we need
> to strictly stick with new netlink rdma interface and just forget about
> the old sysfs one. Distros would have to backport the new kernel
> rdma netlink api.

Thanks,
It looks like that most of the comments are in favor of netlink-only
solution.

>
> Yes, this will be little bit more painful at the beginning, but in the
> long run, I believe it will save some severe headaches.
>

--JjNtGRvLZqzR8wa5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkOv7kACgkQ5GN7iDZy
WKdDHQ//doe7hU8y+mI6aEuFKRpft04YRNGvV/l64AhtRBUWFzUcVP81h+AtHr5M
SE0lPk4JxRwybsOst927koDGxQBmr6i3+7nIllxFbDIToQKjJcozyIj2x5AZVtcz
Eq/3k9d/zpTc9P6Zxm9ac/ofJVwl7ZA32yo4cdKhvCxstIuyDU2reMsic/U9ponx
QzIUlE+l/csjSbg//9yK8ixL6fhP1bZPVv5zKKCfAmZNmQXIjCQVfx94QKZr89JG
xD7wo3LiKxUhx44i85Sa7QHvIiOGvMbAVLBl9C6eHw3/LP9bklv+eo16PYjwxN6Q
CxX+y06ZMoaEs2edykAy7sDmODYrqFKGWK5jgllGhc89PX3FKblkVc9MxNUIviAm
3Wdokw2EK/aLUW58WBjyzBsLfpjcenz05fTJO/z0n79v7jsbYZdzhY9zGwguqHPA
1pPJxB4TfoYhs+ZqYJuM4SuA21znhWv7Stk0LzqAdYz0rbsoKijmv2Gvp0ckfVtf
lW3oitgBdBN/+mx+QVKOLJ+NvL4CgyKz78JuQqnFm4tsQBYnbh7d8ALin34c3YBB
dmJzwGGylDnbDHAINFgfF8lzP3WgylfEWNoQbPoiTdEnm7edHdrTRYedcE3y93PH
sjgZ0sdjkXXOWYCmUNxcKAieJX1LoYpBXvue8vFJDxk30vr6OG0=
=wmIw
-----END PGP SIGNATURE-----

--JjNtGRvLZqzR8wa5--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
