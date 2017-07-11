From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH iproute2 V3 0/4] RDMAtool
Date: Tue, 11 Jul 2017 10:09:48 +0300
Message-ID: <20170711070948.GS1528@mtr-leonro.local>
References: <20170704075541.12544-1-leon@kernel.org>
 <20170710074325.GA1853@nanopsycho>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="R6d/YZw7aFPcgCGm"
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170710074325.GA1853@nanopsycho>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--R6d/YZw7aFPcgCGm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 10, 2017 at 09:43:25AM +0200, Jiri Pirko wrote:
> Tue, Jul 04, 2017 at 09:55:37AM CEST, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org wrote:
> >Hi,
> >
> >This is third version of series implementing the RDAMtool -  the tool
>
> s/RDAMtool/RDMAtool/
>
>
> >to configure RDMA devices. The initial proposal was sent as RFC [1] and
> >was based on sysfs entries as POC.
> >
> >The current series was rewritten completely to work with RDMA netlinks as
> >a source of user<->kernel communications. In order to achieve that, the
> >RDMA netlinks were extensively refactored and modernized [2, 3, 4 and 5].
> >
> >The following is an example of various runs on my machine with 5 devices
> >(4 in IB mode and one in Ethernet mode)
> >
> >### Without parameters
> >$ rdma
> >Usage: rdma [ OPTIONS ] OBJECT { COMMAND | help }
> >where  OBJECT := { dev | link | help }
> >       OPTIONS := { -V[ersion] | -d[etails]}
>
> Do you plan to add "mon" any time soon?

I don't know yet.

Thanks

--R6d/YZw7aFPcgCGm
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllkebwACgkQ5GN7iDZy
WKefEw/9HKhJ4VKvZhENsebqL5HAOIJ+XRjyE8HuqqwCYsBO2oFepVj0quwYoGEy
oQfNDoSYPaU4QHxzhfWHKqrIxgoGUXCCD8wi4DeqVCfUK5ihb78+zRalWx9h7pix
kaJu5utpOJ70g2E400slc/0Kcg/ckE3zqxamqA/B8Dg8jUVSAeR++T9IsX+h7GiN
x9JmQOf4uDIQCXNCkYwJfnazQJLx2rnlbzt43vpEiJzCY79ajJ0bHT+PCecyiFA/
wIv82mUwZGNV7YZA6+jIiW40yWbEVwgPji0MF2kDSHn90Mf18bYXIck+jchPcYVD
jLye9qLPv/p5BRXqfA3IYpcYOMjvZq17TU/TQTMzxutezcaGNrvaykI6TjHlVY6P
NRFxzxl+uyZfL6BOnp1xRR9AhNIY3wpQM7cfL0nB/0aGYTD1Zsd19zyeBIV4OkN/
m0kx///nmtQqDUe+0LN85YeqR1fFFa944cui3ef5GoBowua5SEZED8+2i586btnB
7zk1wULIzzeHp2b6Xd36yKvAFc2X70sc3ybUlFmSXKK5QMNGFcSearGX+OWTwDD6
wO7k3DlyBMyy1G7QlwqMpBWOzHRtZrxjM1VgFthKdReAcy65DCn4TCihyKzubfBm
gRFDsoXvk5RAMOVAqhHUQqtN+2799erdDnAyWrdD8yHLrRwUyF8=
=2KtY
-----END PGP SIGNATURE-----

--R6d/YZw7aFPcgCGm--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
