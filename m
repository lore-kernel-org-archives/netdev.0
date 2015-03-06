From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] ixgbe: make VLAN filter conditional
Date: Fri, 06 Mar 2015 01:34:16 -0800
Message-ID: <1425634456.2556.160.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E4EC48@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-sOFoaD3f3ERRMztg5r77"
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E4EC48@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-sOFoaD3f3ERRMztg5r77
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-06 at 06:04 +0000, Hiroshi Shimamoto wrote:
> > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> >=20
> > Disable hardware VLAN filtering if netdev->features VLAN flag is
> dropped.
> >=20
> > In SR-IOV case, there is a use case which needs to disable VLAN
> filter.
> > For example, we need to make a network function with VF in
> virtualized
> > environment. That network function may be a software switch, a
> router
> > or etc. It means that that network function will be an end point
> which
> > terminates many VLANs.
> >=20
> > In the current implementation, VLAN filtering always be turned on
> and
> > VF can receive only 63 VLANs. It means that only 63 VLANs can be
> terminated
> > in one NIC.
> >=20
> > With this patch, if the user turns VLAN filtering off on the host,
> VF
> > can receive every VLAN packet.
> >=20
> > This VLAN filtering can be turned on or off when SR-IOV is disabled,
> if not
> > the operation is rejected.
>=20
> Hi,
>=20
> any comment about this?
> I added a warning message and prevent operation during SR-IOV is
> enabled.

Yes, the warning message you added says nothing of the huge security
hole this exposes.  We need a message the correctly expresses the
dangers in turning this off.

Also it does not appear that you addressed Ben Hutchings concerns, as I
asked.  Correct me if I am wrong and you did address Ben's concerns.

--=-sOFoaD3f3ERRMztg5r77
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU+XSYAAoJEOVv75VaS+3O2ukP/jal6mW5QuqKck/6NAU24MMA
qkLXjaquWMJckNpK8AG3lMWUjuZlU0JGjvJup8cmldg7bGQJAsPvzty0OBxFbBoQ
mbuwJEp/Fd0ERUZLq8J5XAIxVLPFmcGsZ8a5MA/2lz3YA+eFfOjoB8rivptfuY00
f89m8bNQC8wyELhjl72dCfVI2sRyH5bE+r8cE7ftYTPaCXW0mr8ong3qzGpOfbav
XOn701B+MODghAVpLu+yhdtIsariyfG6Ue5vtT6mhzHmIF4a7bsadCLI1BNLn9P4
FfqxPWGUeFDZtMTG5JjrIYjfeiFzcAU1d7LXQViL4cz3OGi63VTHSeDfWi6dYl3v
7vL5QwgacVQ9rXDohYTiA93gQvO62sgJaYUYV1RjLuu8yOnP4HiEo+M0+hmJ0Z7e
TQ2z2I0VItlTuivpre1iQ8apBS6GjcPQmrAo4BjwaZSrRKjcBZRz6QVwEwr1bzap
48RzvjQEKEDIjgAjlRANaJxqBxfummqwkodHOrv/M3L4N/nhzmwwCcqvBTCPHS/L
F8giIWQPAMg2hxVUyRcW2RxhWfFQ9q7WAh+842aUrLjmBfz/SPIMIaHadHRZpJHo
q/jaRDjgdcPsrRdyMAtLYOBzv47suXSPX++ucy3B+a4nfcZ0QQi/HJn4EQ+D1RCw
dNIMq/Ykzz1DGwxaw1oq
=+f2W
-----END PGP SIGNATURE-----

--=-sOFoaD3f3ERRMztg5r77--
