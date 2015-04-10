From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
Date: Fri, 10 Apr 2015 12:48:32 -0400
Message-ID: <1428684512.2980.336.camel@redhat.com>
References: <5523CCD5.6030401@profitbricks.com>
		 <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>
		 <20150408201015.GB28666@obsidianresearch.com>
		 <1428590070.2980.190.camel@redhat.com>
		 <20150409160123.GA31353@obsidianresearch.com>
	 <1428614348.2980.287.camel@redhat.com> <55277FE8.50107@profitbricks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-QuncKVKZ/VwFHW4+TW57"
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
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
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jac
To: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55277FE8.50107-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-QuncKVKZ/VwFHW4+TW57
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-04-10 at 09:46 +0200, Michael Wang wrote:
> On 04/09/2015 11:19 PM, Doug Ledford wrote:
> [snip]
> >>
> >> I've written this before: The mess here is that it is too hard to know
> >> what the call sites are actually checking for when it is some baroque
> >> conditional.
> >=20
> > The two goals: being specific about what the test is returning and
> > minimizing the bitmap footprint; are not necessarily opposed.  One can
> > do both at the same time.
>=20
> This could be internal reforming after the cap_XX() stuff works for core
> layer, at that time we don't need to touch core layer anymore, just
> introducing this bitmap stuff in verb layer, replacing the implementation
> of these helpers with the bitmap check, and following the semantic (descr=
iption).

Agreed.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--=-QuncKVKZ/VwFHW4+TW57
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVJ/7gAAoJELgmozMOVy/dNs8P/iMI5mMLG7Tpr4qB4UWJfTXr
AUsEynKowlf/xQtqU0kJn1jITyl3HttN7QJfrtx66PnJ0kj+Qg5WN17mVP36Vicu
CJ6sxO9b5Rp1nwCTL5+OHdNVMeuxfrch7/pMb729PuRwpGrTzpUf7SDXI55zOVk1
z55HmezbE82dUC7DpRx3+NE/BBX2V51/eCJpim6Cf6MMyPq4FkGfPNldvzaxnPb3
HQ4ZGkA+JvtLLdNpqOb0dXZcTg0XMK0KmgAJrr9eEwkGu3c+noP3heYQE8ROHfw/
IPLhTW7DOc8G8U1WoGWWKyYshpc3SlmvKuQUM362Jf9IyGY4Lv7DnOhnXdDjVEV4
ew+CeluxoeXfJhynntrvaT87+I5aYEDYYglEkgrC4eSEzlaHwtX0KPC0E6Ck7inR
aKr+YMaZMG5cB6tncdNoKPr7E3WlYwRiLmqTBVorFNwsqu4vYX9R9GZmfbWFv2/u
6udLt76al7Kp1LbCb9u+e0H/g3Ld+OESwPhKG/vQCzbc9LqD/EybmReJoxyOmRJe
lL8fMZ7IyXu8CTNkqo4YVKiIqXLAZAIZnx14AgxG697sU3BwNoh12bOpeJXKilxy
597z2Y4XmL8TOvN66dMhdSku7KB8KGjqZDfPlBfcvnYRkHPDa3qcZgFQRPx2k1Bl
8efZl6lKwCuPAFhv0dCN
=F4q2
-----END PGP SIGNATURE-----

--=-QuncKVKZ/VwFHW4+TW57--

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
