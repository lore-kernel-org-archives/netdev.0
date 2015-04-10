From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
Date: Fri, 10 Apr 2015 14:17:20 -0400
Message-ID: <1428689840.2980.375.camel@redhat.com>
References: <5523CCD5.6030401@profitbricks.com>
		 <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>
		 <20150410074805.GA11855@phlsvsds.ph.intel.com>
	 <1428685843.2980.353.camel@redhat.com> <55280D51.20402@talpey.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-4C6quO/3JxIasEeMQ+Xu"
Cc: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Mike Marciniszyn <infinipath-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Upinder Malhi <umalhi-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morge
To: Tom Talpey <tom-CLs1Zie5N5HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55280D51.20402-CLs1Zie5N5HQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-4C6quO/3JxIasEeMQ+Xu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-04-10 at 13:50 -0400, Tom Talpey wrote:
> On 4/10/2015 1:10 PM, Doug Ledford wrote:
> > As per my above statement, rdma_transport* tests were testing the high
> > level transport type, rdma_port* types were testing link layers.  iWARP
> > has an Eth link layer, so technically port_is_iwarp makes no sense.  Bu=
t
> > since all the other types had a check too, I included port_is_iwarp jus=
t
> > to be complete, and if you are going to ask if a specific port is iwarp
> > as a link layer, it makes sense to say yes if the transport is iwarp,
> > not if the link layer is eth.
>=20
> Not wanting to split hairs, but I would not rule out the possibility
> of a future device supporting iWARP on one port and another RDMA
> protocol on another. One could also imagine softiWARP and softROCE
> co-existing atop a single ethernet NIC.
>=20
> So, I disagree that port_is_iwarp() is a nonsequitur.

Agreed, but that wasn't what I was calling non-sense.  I was referring
to the fact that in my quick little write up, the rdma_port* functions
were all intended to test link layers, not high level transports.  There
is no such thing as an iWARP link layer.  It was still a port specific
test, and would work in all the situations you described, it's just that
asking if a port's link layer is iWARP makes no sense, so I returned
true if the transport was iWARP regardless of what the link layer
actually was.


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--=-4C6quO/3JxIasEeMQ+Xu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVKBOwAAoJELgmozMOVy/dGqYP/jn0V35kY+zkBjlX6yghcjUF
qpSa2iZvrJuuJ/VSaA7UZzT7BaD/W7iVT2WKN8i020LfIImmRetW7nTaJiedyGCN
Csk3l8NU6yWcUnopx99RQBko+My+xGxs88rdyY2ffvvYmQEclN3UDoGIPo3D80du
VEO8mRFSZP9QA20sM4Uzp54xuCJfvVwydPpbuubvrQsXdvgflJ84Gqtng7Yy0/Qx
1INqAYGbS134GJMVZrumU+ZpB5Q2QWAO8SrdF8mmDM58LwFS0lqQ1qrPYKHEkLX6
0s/4Uvzv7UBwosYmJMvvI5ZWHNUDKHSod3DqiUTyKLmTv3aXGKKiaAXY1InPdJQS
ssMxCf61rT+3HukNCpS206fNpgdRvM6nlFnEl3AoWnPaJ2xfU43r3p2u07snmiNo
IlQO7FcdC7rHfwI9tpe1cgOV0QR8Gyde7+wd6yqNdiAJ4rtxxqyIWmz3LicaKYvv
yWMQGqkG61u0Y1iHi1S0e7wb1KkjhmY2n+XK0uDJUnRdFmYCAOAKV4KByDccX2hU
U+P0ZKz/vVj1JgTL5Qr5HoEhe2crcuL5lPdPeu019xhPdLZABE0uG4cr4auNtwBR
4Hv3EAezWmk+uEFs5edPSNzo1cEOnRwBgVNyKqsaaxo0kJCEj8IcBojpZqQUn1hk
1+QgA70ZHvO2AvhU9Qrj
=FLya
-----END PGP SIGNATURE-----

--=-4C6quO/3JxIasEeMQ+Xu--

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
