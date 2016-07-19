From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V2] Add flow control to the portmapper
Date: Tue, 19 Jul 2016 08:40:06 +0300
Message-ID: <20160719054006.GF20674@leon.nu>
References: <1468869810-64420-1-git-send-email-shiraz.saleem@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="L2Brqb15TUChFOBK"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mustafa Ismail <mustafa.ismail-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Shiraz Saleem <shiraz.saleem-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1468869810-64420-1-git-send-email-shiraz.saleem-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--L2Brqb15TUChFOBK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 18, 2016 at 02:23:30PM -0500, Shiraz Saleem wrote:
> From: Mustafa Ismail <mustafa.ismail-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>=20
> During connection establishment with a large number of connections,
> it is possible that the connection requests might fail. Adding flow
> control prevents this failure. Change ibnl unicast to use netlink
> messaging with blocking to enable flow control.

You are the one user of this new inline function.
Why don't you directly call to netlink_unicast() in your ibnl_unicast()
without messing with widely visible header file?

Thanks

--L2Brqb15TUChFOBK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXjb02AAoJEORje4g2clinbtYP/0SqzBcNMfeyoycc/6gai7nV
xd65jCRERBPCgUTI1JcYZVDodLMzIb/uMqDoq5SANzdCVa+ROPo+s22weajMdXBu
77dcaBL7C+p8Q8J6oSZMNdjumNu9ckaPzqbiRlWwxRvCJatik+mK/9svxB58e73g
FFIZ5IMsN8zfYGAtnXWARH4onwYpod60ei90TTpZ3Mbpu5qrC0grb0iiztE+1bom
JrnNeWKdy8Z+l8+7WhMnRMifqWDWqcVt2FnDuwK8JmwunmzLlU0Inc79CvDZ5Vsd
Aa6c3GnQSOnZZark3TVJvj4Jzj0jtTCSGOmSEB6LddjRHrDwrzxJ6IohNIoVxAqD
tL2bxdZqb5H8CidCn/LPJjDXUCe1cvoGZVCl8r9cXSqVRq6pyJ92U6NqxqebkDcN
sDIQJ8UxnIUtXgoKsB95ipbhNiP8jxGzh0ha8gQ7Lzf7txd5aHVXI23YidPn337H
NBZVYFqCCqfNVtu+7Nr5rQoh045BXCMiOaBY+nBQsMIn7sjsN6l2bCxkso5SnSy0
lHB5ehUV961yB0irDrkt4iXauwPxTb/RQXUwA2nSZodQ0jg58QVpjvj0iu9AJR+e
lHz5FashujDLn2pDkMwiCTf1klX4gfNNvBQoBXpnaTE7MvUFjDwPLPGSUqrvqdsN
QGzLZ3bg5sWqqm/oGvP0
=D4Yv
-----END PGP SIGNATURE-----

--L2Brqb15TUChFOBK--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
