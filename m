From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: Netlink messages without NLM_F_REQUEST flag
Date: Thu, 8 Jun 2017 08:08:25 +0300
Message-ID: <20170608050825.GJ1127@mtr-leonro.local>
References: <20170607161901.GD1127@mtr-leonro.local>
 <20170607163758.GA25313@obsidianresearch.com>
 <CALq1K=Jj_jJ5_OAiiws-es37tFEsLeLJeSvnU+bfwd0KLkGM3Q@mail.gmail.com>
 <20170607164750.GA7507@obsidianresearch.com>
 <20170607170037.GG1127@mtr-leonro.local>
 <20170607170702.GB7507@obsidianresearch.com>
 <20170607181810.GI1127@mtr-leonro.local>
 <20170607183511.GA10225@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="/0U0QBNx7JIUZLHm"
Cc: Kaike Wan <kaike.wan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, John Fleck <john.fleck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        RDMA mailing list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170607183511.GA10225-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--/0U0QBNx7JIUZLHm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 07, 2017 at 12:35:11PM -0600, Jason Gunthorpe wrote:
> On Wed, Jun 07, 2017 at 09:18:10PM +0300, Leon Romanovsky wrote:
>
> > > AFAIK, that is different, that is acking and retriggering a single shot
> > > notification, not completing a kernel initiated handshake.
> >
> > It is acking that message from user was received by kernel and now
> > processing.
>
> But isn't what is cared about here - the SA thing needs to send a
> request to user space and collect a reply, it runs the protocol
> backwards from normal.

Thanks all, this explain a little bit "RDMA anomaly".
I'm not sure that I saw such scheme in the kernel, does anybody else
in the kernel use such backward scheme or this is RDMA-specific?

Thanks

--/0U0QBNx7JIUZLHm
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlk428kACgkQ5GN7iDZy
WKf5vA/9GgxHg8dpiKLi4NCGWzf9kzsW2LlA/XwnwOC5l+s/PZl34Nvkp1bITzDX
HwTuJVAsTD4udac1GbzJ9qADEknPrC2pAoShpFGQmhMLGJqWUxXgBOXUbJkNBXDU
4UbmXefluUjJ/I57koN+KPzeV/88pYvzHjhU92CcgchAjNBnvHVuRueJdYhgP4kz
aOgIxx/GjMLv6xrhvj89s5Ke91HOSyCOx/C7YCAWSfjqo26n/+GXNJM6K97s1z37
3XdhFlQnipt/buE7KUXiUnh9QUIOJLsyHCKMT6c31P17pAA1TQQOup3vT9N9oCU6
kiliVq7B1Cv0vMM90enThzqlYh0H3llwTnXazButKM3KiZlPgY+eTtaYx/Hvp34x
kc6PN0PQ3JbCFxtgNj99Kvw/YmQjB5ChFaxco2I1mbvXPi/AGtMVyFUtntm/yuls
falUCl/hRnzbYG5zNqGPO6eOrpSosr1B5kX7SYejClFgR4WwlKGkQX8CGsW07kK6
TEqnBWb/9996SWx7upWRepPrq8bWtWaS7osPrFhT54cBqRpe7xDCQ6eHClZy25SD
iRDvpicOAGRDIcd+wM1RhPIid8QUbsjnNpYhvK8AH1sjjQ+RPB2WTDwe/+rT27oe
R205Vw8JJfa8QbKoetFE6hwmjnJj4hnZRibkHMwcwG9X0wXUnvM=
=f2v8
-----END PGP SIGNATURE-----

--/0U0QBNx7JIUZLHm--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
