From: Timothy J Fontaine <tjfontaine@atxconsulting.com>
Subject: Re: r8169 MTU greater than 1500 causes corruption for other
	controllers
Date: Wed, 20 Aug 2008 17:17:24 -0400
Message-ID: <20080820211724.GA4100@tophat.atxconsulting.com>
References: <20080820170951.GA1771@tophat.atxconsulting.com> <Pine.LNX.4.64.0808202053510.24321@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VS++wcV0S1rZb1Fb"
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: =?us-ascii?B?PT9JU08tODg1OS0xP1E/SWxwb19KPUU0cnZpbmVuXw==?=
	<ilpo.jarvinen@helsinki.fi>, ?=@tophat.atxconsulting.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-70-62-214-221.central.biz.rr.com ([70.62.214.221]:34271
	"EHLO tophat.atxconsulting.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752048AbYHTVR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 17:17:26 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808202053510.24321@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 20, 2008 at 10:21:11PM +0300, =3D?ISO-8859-1?Q?Ilpo_J=3DE4rvine=
n_ wrote:
> Hmm, there was no explanation why the tp->rx_buf_sz to pkt_size change
> was made in that commit (I have no idea whether those sizes have to match=
=20
> to other places that use tp->rx_buf_sz)... Below is a patch to revert=20
> that part of the change fully though it could be enough to change just=20
> pci_unmap_single arg (but that would probably need also=20
> rtl8169_mark_to_asic arg to be changed to match pkt_size).
>=20

Excellent, with the patch applied transfers over NFS seem to be going
smoothly.

> > Below you'll find a list of files referenced from REPORTING-BUGS that
> > are meant to be helpful, including the lspci and module information,
> > they can all be reached from the toplevel directory index
>=20
> Thanks for the detailed report btw... :-)

Thanks :) I was more than just a little intimidated by my first post to
LKML, and I wanted to make sure the first reply to my report wasn't that I
didn't have enough info, or that I presented it in the wrong way, or
hadn't done enough testing with it. I was also more than prepared to
wait weeks for someone to reply, so thanks for the quick return! :D

tjfontaine

--VS++wcV0S1rZb1Fb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkisieQACgkQfTP/nQJGQG0HsQCg0kuDXCRFL8B0dtk1+Y8T4U1V
y8gAn2kM8/l3q8iyApo+EPCBRSm4VUhe
=MZi0
-----END PGP SIGNATURE-----

--VS++wcV0S1rZb1Fb--
