From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
Date: Fri, 10 Apr 2015 14:24:26 -0400
Message-ID: <1428690266.2980.381.camel@redhat.com>
References: <5523CCD5.6030401@profitbricks.com>
	 <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>
	 <20150408201015.GB28666@obsidianresearch.com>
	 <20150410061610.GA26288@phlsvsds.ph.intel.com>
	 <20150410161551.GA26419@obsidianresearch.com>
	 <20150410173836.GE10675@phlsvsds.ph.intel.com>
	 <20150410180455.GA1277@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-Ad+FZjWd0dolk5FowOcs"
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
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150410180455.GA1277-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-Ad+FZjWd0dolk5FowOcs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-04-10 at 12:04 -0600, Jason Gunthorpe wrote:
> On Fri, Apr 10, 2015 at 01:38:38PM -0400, ira.weiny wrote:
> =20
> Hiding meaning is to say 'only run on IB or OPA': WHY are we limited
> to those two?

For something else, I might agree with this.  But, for the specific case
of IPoIB, it's pretty fair.  IPoIB is more than just an ULP.  It's a
spec.  And it's very IB specific.  It will only work with OPA because
OPA is imitating IB.  To run it on another fabric, you would need more
than just to make it work.  If the new fabric doesn't have a broadcast
group, or has multicast registration like IB does, you need the
equivalent of IBTA, whatever that may be for this new fabric, buy in on
the pre-defined multicast groups and you might need firmware support in
the switches.

> We can see how this might work in future, lets say OPAv2 *requires* the
> 32 bit LID, for that case cap_ib_address =3D 0 cap_opa_address =3D 1. If
> we don't update IPoIB and it uses the tests from above then it
> immediately, and correctly, stops running on those OPAv2 devices.
>=20
> Once patched to support cap_op_address then it will begin working
> again. That seems very sane..

It is very sane from an implementation standpoint, but from the larger
interoperability standpoint, you need that spec to be extended to the
new fabric simultaneously.


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--=-Ad+FZjWd0dolk5FowOcs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVKBVaAAoJELgmozMOVy/dhWoP/1HozPXRkPbICFJJJv9gj3DK
wpf+dC3DwI//JeZ2jCy13kiSIPqtGcuNusl+y698yE6ruWH+LnmSWoD4q6JiHOAy
LtAdQ/9C15+weAxercSMvW8DUNqf4sKffD797GbOG/u6Is5aDu3rqYT+nLG0b9Ey
EmRvb5V1R1wZ0kysYJrqf4XhFep9Ur9lKlryeYmvWBgbQf/7soPubSKjyFXUmKTB
Ww3u7anRfvfcU3pJSa36HA5EDj2LGbrBCF9abn6IcrHlfMLlrbFDDnVy7O3ZFUoN
vEluqBYZv7Fkl13xWVSJ1QObJki9UXFAYiSBu5TRmv11/LEBqnfYkto6u+LH1UPs
n3U71ZoGN57d7arcWSiPtxO4WYDlP2671gSQMhy80ytToyEDd1T+YC1fluEMR9Ox
EUq2r7vMK427QF6o2T51BJgVRB7q9qqTVZtv+JaO8tzsOZRBIPuPyOYAjCOxhP5n
ZNzRfHIaU5qTGnjF7a1xIJiXe2nB8KPMuJMWluzsOkuhitxjbxK9xli6ZYppuqGf
KTcww2E3tlL/aAN8zEihkY0KRvab+YO9olZz0xw00bAwyZ5gc2NbljzhobHUecrH
0ib9fYWiBfkHlUT2qjO49L5PWaWqGLOg9OyTbYtYr4BoKiWo8tLY5wPriDrNzCyQ
J1kgu3YzuYl21gWNYuUG
=K39F
-----END PGP SIGNATURE-----

--=-Ad+FZjWd0dolk5FowOcs--

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
