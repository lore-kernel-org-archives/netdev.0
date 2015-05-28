From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Thu, 28 May 2015 14:22:40 -0400
Message-ID: <1432837360.114391.35.camel@redhat.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
	 <1432647280.28905.107.camel@redhat.com> <55671309.6080303@mellanox.com>
	 <1432822057.114391.26.camel@redhat.com> <55674077.5040707@mellanox.com>
	 <20150528174337.GA10448@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-c7OMWg5gF1v5UBMrYl2S"
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150528174337.GA10448-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-c7OMWg5gF1v5UBMrYl2S
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-05-28 at 11:43 -0600, Jason Gunthorpe wrote:
> On Thu, May 28, 2015 at 07:21:11PM +0300, Or Gerlitz wrote:
>=20
> > Anything else except for that (you said "reworking of the network scrip=
ts
> > and NetworkManager assumptions to make it work")??
>=20
> IPv6 becomes very broken, child interfaces will generate the same IPv6
> addreses for radv and link local resulting in duplicate address
> scenarios.
>=20
> About the only thing that will work properly is statically assigned
> IPv4 addresses.
>=20
> > I don't see why we should stop the whole RDMA containers support train =
just
> > b/c we found out the IPoIB DHCP bug which was there for few years befor=
e
> > this effort started.
>=20
> I don't think that is what Doug said.

Indeed.  There is no need to scrap things, but if the design as it
stands, and the intended means of creating objects for use in
containers, is going to result in an unworkable network, then we have to
re-evaluate how the container constructs are created, and that then has
possible consequences for how we would get from an incoming packet to
the proper container.

I'm not trying to stop the "support train" here, but at the same time,
if the train is headed for a bridge that's out....

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD


--=-c7OMWg5gF1v5UBMrYl2S
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJVZ1zwAAoJELgmozMOVy/dSSYQAJqif1VrR0/mhmQgRqJHh8Ze
xQ2Ewm+84ajmpBO960/PrzMzyMUdiJUgYtABXg8Vsnx6Xr1T0ZHOldmNVpHEumYv
9ktDuUVP6VatSPTSpuNMx1ibDqRmBN3lcUbJEV6brHW2qQ2QxiIrxqiAXzaEmaKX
2UtBhwwJkgcfrTRZKjnDpMaRpvWsbGaO4ilYe4WBjAxRaOEaxQKTHVMXM3ATlqwE
QYUBxSSJ1+hjNogVFnPWll43jxMSvoCkk+UgwpqouiT5jGTS/q6d9Ebt1yD1Xbck
7rVUZKn/msvwQiZ1SjXFJPuzx2+rE9FYvyhrlSewALIplqsh5GVllGh4hWj0szk3
haqyrwUzj2kDt8HdKMyxMYHOcpt7Ns/7GHfSwt5Ms5/CA23k2LQaBDmH+6r+EbQx
INIUrLYLKQFUeaFLH8jo5qskAnSaDCigGute9dbt7acVDxpajvaB1hwuiy0r4HRx
D+NBme3yxnYMBNH0CYUHZuPdlnr+q4FRhbxtteXDolppx9iE5dwMUalvuSwOGZAL
yPkGt5sTJ9hr9BaNLse4h+oicEM030ONZMudB1NTRjaLmYdllqf/G4zZF5c+ZIxw
cnCYveU6wPlSQbbTGt9v9HE6RyAo+1VCVVchlll/mFOYTJYc/D8K+7lCQg9Fk/+B
0gCknS5Voc7OUBizxLje
=HOXL
-----END PGP SIGNATURE-----

--=-c7OMWg5gF1v5UBMrYl2S--

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
