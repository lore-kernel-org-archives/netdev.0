From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 03/14] i40e: Add PF reset when Malicious driver
 event for PF
Date: Tue, 24 Jun 2014 19:35:15 -0700
Message-ID: <1403663715.2311.8.camel@jtkirshe-mobl>
References: <1403659585-32055-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1403659585-32055-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1403662597.12657.4.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-uSLlZqHJdV1eNoeHKOif"
Cc: davem@davemloft.net, Neerav Parikh <neerav.parikh@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9644 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752322AbaFYCfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 22:35:43 -0400
In-Reply-To: <1403662597.12657.4.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uSLlZqHJdV1eNoeHKOif
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-06-24 at 19:16 -0700, Joe Perches wrote:
> On Tue, 2014-06-24 at 18:26 -0700, Jeff Kirsher wrote:
> > From: Neerav Parikh <neerav.parikh@intel.com>
> >=20
> > As per the spec when the PF driver receives a Malicious driver event
> > the queue that caused the event is already stopped and it is expected
> > that the function that owns the queue will reset the queue.
> > In some cases it may not be possible to determine the queue and it is
> > suggested to reset the whole function.
> >=20
> > This patch takes the later approach when the event is owned by the PF
> > that owns it.
> >=20
> > Change-ID: I40f9764a6a5e068c0ef8438db00c5aa9c2c6c1c8
> > Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> > v2: added punctuation to print statements and code comment
>=20
> Comments are good, but I'd suggest removing trailing
> periods from messages as close to 95% of the messages
> in this driver do not use them.
>=20
> $ grep -rP --include=3D*.[ch] -oh '.\\n"' drivers/net/ethernet/intel/i40e=
/| \
>   sed 's/[^\.]\\n/X\\n/' | sort | uniq -c | sort -rn
>     621 X\n"
>      41 .\n"
>=20
>=20

Just to note, the punctuation that was added was a comma and not a
trailing period.  I know that we have tried to clean up the trailing
periods, I will see about going through the driver and put together a
cleanup patch.  Thanks Joe.

--=-uSLlZqHJdV1eNoeHKOif
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTqjVjAAoJEOVv75VaS+3OGzoP/ArUjS96bHg3pYr6Sf4zDF48
WJOqdZbno3hOn3ILWI36AC9Nq+fJUHbfHkfZzrg3jkYD+qfvKGmSlBDdwPpp8ULA
uXI+KmKReOShLPxzE99d/BgRKAADVxQjs2iSPWAnhJXgIMLu8VqnvVSwFBZBYdrL
+/M/YDSLXmaJI9WgJ7JIl3runID3pL40UEgXsB0hO0cygQ8n9Hqe92Zie9hrIHts
38LPyXbR2XcFCbSPzRGYInQ8/mWByMhs3UIojL1ins+O//WeuZfqTCwU6JTGLNfN
d6tMYlHDPNVFKoVvfrC8r7b1QFdMz1bUniR1TNFc+EngjbTKL1ijery38HTu1El4
SpXr68UTsKlAQuLGSO1+3WYcxVsv+xVLtO3daZiMuxWpdY/WRFjnkgRd2iPG2+8E
xWzcaAa/Iaee5b303LI6zCf90RVZajc051mQW8SKhKWAajJK+A3eAeQqk3Rfk3d0
wJUHj81FrXqIoivFaoqAy7WsqHSwLGsIbSsdJL9tO69j9PnDFANwiWqULZ5wb/ix
DsQhcj/6OnKG+A4w4yESwtK18LPdMe2MbK8VHyt0Tu0Ig4u5OVKSN8xeUL/+2xfM
/FW1DGs1iq4YcQljHpSt5et76WiWQ0S9kTW9PP+syzKhho2nlfLdofrRCfgYBR/Z
fiYNfNPCfhHqHvjBZwVq
=7XGf
-----END PGP SIGNATURE-----

--=-uSLlZqHJdV1eNoeHKOif--
