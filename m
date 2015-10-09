From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: simplify configfs attributes V2
Date: Fri, 9 Oct 2015 16:37:51 -0500
Message-ID: <874mhzu3io.fsf@saruman.tx.rr.com>
References: <1443879179-22280-1-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-="; micalg=pgp-sha1;
	protocol="application/pgp-signature"
Cc: Andrzej Pietrasiewicz <andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pratyush Anand <pratyush.anand-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>,
	<target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	<ocfs2-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Nicholas Bellinger <nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443879179-22280-1-git-send-email-hch-jcswGhMUV9g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org> writes:

> This series consolidates the code to implement configfs attributes
> by providing the ->show and ->store method in common code and using
> container_of in the methods to access the containing structure.
>
> This reduces source and binary size of configfs consumers a lot.
>
> Changes since V1:
>  - a couple fixes for unintended changes in the uvc driver
>  - moved a few CONFIG_ATTR() statements around
>  - fixed up the documentation and samples in the last patch
>  - added a little rather pointless blurb to the patch description for
>    various patches

For reference, I'm fine if you guys take all patches through FS
tree. Another option is waiting for dependencies to be merged in v4.4,
and the gadget changes merge in v4.5, whatever works.

Acked-by: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>

=2D-=20
balbi

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWGDOwAAoJEIaOsuA1yqREVbwP/RGi9MS4VH0KpNpqz+pPD9s+
pE5Tl142AtEUAGYxlI5jariOO2ICknIrRZ0wiiYEaZ906tZMIrSiIZZc3OiL+wG3
9IL/I4nws0MhxS2MLRjYbzfvjW4oH8PG9hCk4n/saBscObGlGf3q5yh9RBRz//s7
/ClpYTOOQ+VPrdiJwXj/L90vynGbFrrj7Sd1hIDqeNe/cs3jyvLJ66rpj72lubTC
9pMjbgLOSHmDu+sz8gqA2+OXHbqWlvcSmL6AGnSd6migS/wj+/SvPe+NCqCKuTyb
uZ37qiH6Km/iqFq8YYJMItO2CYHWTU5HsSZs9U+EpjdyGc5HshgXpPgUtgAAPpDl
QJd4HkEnZ0MslPB55hY7FnaIs3WS9CUdNDlnUTc4OEHbi61614TzW1MWngWrlQ40
dXV2jaV3Zn8MgGv5niyNTmMXYsw/wg2HZAcIjOudwCO0lvRcwPFMaQjdyOisH9jV
s+uEqnD8WV84ZZhyfd641LaW3ku+lhVWwMpssywK2gSAIO1VSBuqzyEhhFHBCd8k
z/A817FiN6EoeLIvbzb/rUpMn1DxbE7kXpGJot1PNHhO1iY9CetD+EWi9wD83sKz
8iY8YzoOa+Vg+g/q+bltdC6jfHldNIL1+4Js9xXvjOhIrah8MtkCoUV4+gH5+0I2
TGB6JiuEVf2jLz4d5SuG
=2x8t
-----END PGP SIGNATURE-----
--=-=-=--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
