From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v1 2/2] ethtool:QSFP Plus/QSFP28 Diagnostics
 Information Support
Date: Mon, 27 Jun 2016 00:02:29 +0200
Message-ID: <1466978549.2551.27.camel@decadent.org.uk>
References: <1465860426-30387-3-git-send-email-vidya@cumulusnetworks.com>
	 <1466933589.2504.42.camel@decadent.org.uk>
	 <CAKWE-XqgZ0hnqfLddg+ui4kTwZXzqKjq9vaXPod7fn=wBxByBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yfCAMrWPDWue9DPIf/GM"
Cc: netdev@vger.kernel.org, bwh@kernel.org,
	David Miller <davem@davemloft.net>, bkenward@solarflare.com,
	daniel@iogearbox.net, Gal Pressman <galp@mellanox.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Dustin Byford <dustin@cumulusnetworks.com>
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60348 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751680AbcFZWCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 18:02:45 -0400
In-Reply-To: <CAKWE-XqgZ0hnqfLddg+ui4kTwZXzqKjq9vaXPod7fn=wBxByBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yfCAMrWPDWue9DPIf/GM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-06-26 at 09:40 -0700, Vidya Sagar Ravipati wrote:
> On Sun, Jun 26, 2016 at 2:33 AM, Ben Hutchings <ben@decadent.org.uk> wrot=
e:
[...]
> > This looks very similar to sff8472_diags, only with the actual values
> > separated from the arrays of thresholds.
> >=20
> > Can the structure and code be combined with sfpdiag.c, with the
> > additional per-channel diagnostics being optional?
>=20
> Diagnostic dom information in QSFP=C2=A0=C2=A0has lot more information co=
mpared
> to SFPs and as part of this checkin , basic dom information in qsfp which=
 is
> equivalent to sfp dom=C2=A0=C2=A0is getting exposed as part of this check=
in.
>=20
> Here are list of fields (not complete)=C2=A0=C2=A0which=C2=A0=C2=A0are us=
ed for=C2=A0=C2=A0debugging QSFP
> issues, will be added for this structure in next patch sets
> a) TX/RX output amplitude conttrol
> b)=C2=A0=C2=A0TX_DISABLE
> b) TX_FAULT
> c) TX CDR
> d) RX CDR
> e) RX output disable
> f) Rate select option
>=20
> Please let me know if it make sense to maintain the different structure
> with above explanation=C2=A0=C2=A0or whether it is required to be combine=
d.
[...]

I think there's enough information in common that it does make sense to
use common reporting functions, and that in turn suggests that it would
make sense to use a common structure. =C2=A0You could alternately have the
callers in sfpdiag.c and qsfp.c extract the relevant fields and pass
them into the reporting functions.

The substantial duplication of reporting code from sfpid.c in your
latest submission is not OK.

Ben.

--=20

Ben Hutchings
compatible: Gracefully accepts erroneous data from any source

--=-yfCAMrWPDWue9DPIf/GM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXcFD1AAoJEOe/yOyVhhEJz9sP/2NVLNhHIOrQP3UVfYp3aEIO
A0wlc+PnR8Q/uhgukwcRZ9XXnbqX6wGBWffH6azvamUL871KjlIG8EBcs1ArInb5
P4eUUbH/mcm1BFySKmvgOJ5xdh4J+gzN8EgzEUXXIh69Uub3v+LX4nsBEGjzl8WG
GWyXCNS59iszKDaVtHpdPKIGp+DoxdMrmUJVq1CDf+fB4YbRwlJqt+qMnXOuu7k3
5loN7jMSWReVWdZkIL4pZS+eu7GGIq+rmbLi2Lw11Vsk1sM8Smvi8/Tms/B/NVAA
Z1CK1T8Ji9tznehRLfXg+nB333Ux24gYYCmzl+05fTp3zeKd/oOA8ErWFIDctXgM
KH/RZNkOHZ7GXXvh/FsFWj11/UhtxRK7aPB0ZGX+3SjrvIoMx08AoISTMcJxJQMA
c5FC1P4hYaDMikI1SzhSCCdG6Y1AgKxxiYaGe6jLr5xhOAaiMSwfSSVXny5WW7ZN
/qB575r/nzFxbqmQzP7lVIlSnbh912XBx6wpJQL36noQAg5pQz/Qi5+Gr2oBa6v2
M6Vn/cIBv4bDtSUYLd3iPiKPpgXKxEFk8QVgz3zT0ls8nIO9IC+eeCgb/JHbs+Ew
RhP46ze7iNHGkbKramqknYdPLL/RtexYBh8LLRhh0C8L5vWgVWFD/lKAlWIEIBAz
h2dm4k0HVReQZoCUNxXI
=DbM0
-----END PGP SIGNATURE-----

--=-yfCAMrWPDWue9DPIf/GM--
