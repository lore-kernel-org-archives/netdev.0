From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 00/14][pull request] Intel Wired LAN Driver Updates
Date: Tue, 22 Oct 2013 13:00:56 -0700
Message-ID: <1382472056.2160.3.camel@jtkirshe-mobl>
References: <1382451757-9817-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20131022.155336.2066350912394604583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vT2/+Dmq3tcLpDMKBYSJ"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51806 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149Ab3JVUB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 16:01:28 -0400
In-Reply-To: <20131022.155336.2066350912394604583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vT2/+Dmq3tcLpDMKBYSJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-10-22 at 15:53 -0400, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue, 22 Oct 2013 07:22:23 -0700
>=20
> > This series contains updates to i40e only.
> >=20
> > Jesse provides 6 patches against i40e.  First is a patch to reduce
> > CPU utilization by reducing read-flush to read in the hot path.  Next
> > couple of patches resolve coverity issues reported by Hannes Frederic
> > Sowa <hannes@stressinduktion.org>.  Then Jesse refactored i40e to clean=
up
> > functions which used cpu_to_xxx(foo) which caused a lot of line wrappin=
g.
> >=20
> > Mitch provides 2 i40e patches.  First fixes a panic when tx_rings[0]
> > are not allocated, his second patch corrects a math error when
> > assigning MSI-X vectors to VFs.  The vectors-per-vf value reported
> > by the hardware already conveniently reports one less than the actual
> > value.
> >=20
> > Shannon provides 5 patches against i40e.  His first patch corrects a
> > number of little bugs in the error handling of irq setup, most of
> > which ended up panicing the kernel.  Next he fixes the overactive
> > IRQ issue seen in testing and allows the use of the legacy interrupt.
> > Shannon then provides a cleanup of the arguments declared at the
> > beginning of each function.  Then he provides a patch to make sure
> > that there are really rings and queues before trying to dump
> > information in them.  Lastly he simplifies the code by using an
> > already existing variable.
> >=20
> > Catherine provides an i40e patch to bump the version.
>=20
> Pulled, thanks Jeff.
>=20
> Just a note for the future, and I decided not to push back this time when
> I saw it in this series.  When you have a construct like:
>=20
> 	if (x)
> 		for( ... ) {
> 		}
>=20
> Put the top-level condition in braces too as it's much easier to read
> and audit:
>=20
> 	if (x) {
> 		for ( ... ) {
> 		}
> 	}
>=20
> Thanks.

I agree, I will add that to my list of checks for the future.  Thanks
Dave.

--=-vT2/+Dmq3tcLpDMKBYSJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSZtl4AAoJEOVv75VaS+3Oz5wP/1t0Z7DWcID+KNMkQjL9sLq9
+cbrhLdpE1sOJ3nIdBgKUQ9ZttosbiFtNWjD2jnd43AuPJAZmVUT228oOUXXG0mo
qw3QffU+1mt9IBtiefSeGI/nkjIxSsc5URCMjnm5KkXZeOk5O1RlkpcAH5in34jz
N1qpc9T1+X8DbeIxTNsh1/StTvC8tWu9qzkwTEBV2rk8A+4jpMEY1fgIZMJHzIcL
CmmHoVwRN9VG3W3yn+mDb9hNpnWivzIMPXMM83CWUPVmg9Vr3lswG5yImdE6M0dk
VYclbojjRgWpCiDfgQhaYQ5bFXz/T37xnH8nyiHhPO4KrQb47Mvg9aMwIgbkAMQJ
wCdozRtEa3nm1l4y4DbevsguQZlDz5KzajlY/lJqYwCOPdxa1MBOXI26kl+0xYJ0
9na/JQX9Bp3zH525K8OK+hUZkc8IqD2G7uABL/RFeFNvaWg7UTiUUoDnkjcBHbL5
4smN8p5hHDPdPkKAtP76Sy+muruDv/dEpsV4KyEUQBZbBLKMlT5iMLxDUiWbSfpa
7nfahHBTXFjPpvQP+EgteTjBYwLYdf1cfgyKeU1y5rLz+gd8FSwbZYrI/bboCHzt
Xi0s0J4Qbk9nW3ICA7eXu0U/1X1NiXx3EVVzFlBplGhhRLFW4yZXmcPDZh8YULYW
VtMIvvJK+eoTEMoaV2sk
=TF8+
-----END PGP SIGNATURE-----

--=-vT2/+Dmq3tcLpDMKBYSJ--
