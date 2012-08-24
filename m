From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 04/13] e1000e: cleanup checkpatch PREFER_PR_LEVEL
 warning
Date: Fri, 24 Aug 2012 14:19:24 -0700
Message-ID: <1345843164.3613.9.camel@jtkirshe-mobl>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1345715813-20757-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1345730504.16471.3.camel@joe2Laptop> <1345831348.32359.8.camel@joe2Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-j3ieO0p3H8oxQ1Ut5b0B"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: Joe Perches <joe@perches.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57435 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704Ab2HXVT0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2012 17:19:26 -0400
In-Reply-To: <1345831348.32359.8.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-j3ieO0p3H8oxQ1Ut5b0B
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-08-24 at 11:02 -0700, Joe Perches wrote:
> On Thu, 2012-08-23 at 07:01 -0700, Joe Perches wrote:
> > On Thu, 2012-08-23 at 02:56 -0700, Jeff Kirsher wrote:
> > > From: Bruce Allan <bruce.w.allan@intel.com>
> > >=20
> > > checkpatch warning: Prefer pr_info(... to printk(KERN_INFO, ...
> > []
> > > diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net=
/ethernet/intel/e1000e/netdev.c
> > []
> > > @@ -4330,9 +4330,8 @@ static void e1000_print_link_info(struct e1000_=
adapter *adapter)
> > >  	u32 ctrl =3D er32(CTRL);
> > > =20
> > >  	/* Link status message must follow this format for user tools */
> > > -	printk(KERN_INFO "e1000e: %s NIC Link is Up %d Mbps %s Duplex, Flow=
 Control: %s\n",
> > > -		adapter->netdev->name,
> > > -		adapter->link_speed,
> > > +	pr_info("e1000e: %s NIC Link is Up %d Mbps %s Duplex, Flow Control:=
 %s\n",
> > > +		adapter->netdev->name, adapter->link_speed,
> > >  		adapter->link_duplex =3D=3D FULL_DUPLEX ? "Full" : "Half",
> > >  		(ctrl & E1000_CTRL_TFCE) && (ctrl & E1000_CTRL_RFCE) ? "Rx/Tx" :
> > >  		(ctrl & E1000_CTRL_RFCE) ? "Rx" :
> >=20
> > I think these conversions are not a good idea.
> >=20
> > When you have a specific message format that must be
> > followed, use printk.
> >=20
> > pr_<level> may at some point in the near future use
> > #define pr_fmt(fmt) KBUiLD_MODNAME ": " fmt
> > as a global default equivalent.
>=20
> Hey Jeff.
>=20
> The comment above this change (and the other) reads
>=20
>   	/* Link status message must follow this format for user tools */
>=20
> This file already uses #define pr_fmt(fmt) KBUILD_MODNAME...
> With this patch, the output form changes to use 2 prefixes.
>=20
> Is that really desired?  Probably not.
>=20
> If the comments are old and don't apply any more, they
> should be removed.
>=20

Bruce really should answer this since this is his patch and there was a
reason why he made the change.  My guess was the current output was
providing incorrect or mis-leading information.

--=-j3ieO0p3H8oxQ1Ut5b0B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQN+/cAAoJEOVv75VaS+3OlHEQAIRD9vrBJJNJB5hVJYljGxOv
+nFcc6oqHpH+EUVwFcp/OOJ7JblABidP3uuRWDdCoGYFw444Pwwl/fF3MLAFx8FH
IxmqsDE5NcSmEKhIBUSnFiQtk7Psf6rTAeiiavFfmGkYkEnoO3SF4ek2ikEQZCA+
2jzgQCSrH3rSeGsLmplF0MKkHgcR3HNEdIMti7TmfP4fJxBx900JuTWu2zXzS0DG
5CAqku1o4e+jdBRpWih4KfUmLRoahYpc7ny1h21740ECkJwFMrFYv4wHSbjeDnWv
ESm9bcROY9cbaq7GGSQbPd4Dz5AI8nFs6IKVtPTZ7fzRni+qzUPsco9t6cyfUvUM
QiB9Q/HSQk5LzbUZI2iA9O2yTUZZqkija47t0Ooi8MNAs2ZunOpsADg4v/Ro5svo
/IR5/mmCGE3y3ns7eo8IkxQw+R+tsCuFgpOUWVGqEuLU2tf0z/q4mKHdxWYdl1oo
WFesLUTpd/BW6fNRbadotJupYd/Rbt9bF7xYxNz56V/n9MiT3qsT9xnHmHX2vo3L
GL2MKf6JTE8hs+lE5/Khd538ZAODGYwm5/UW4Skklen8abtWkZE0wsDMJB6cXxpi
nqUqIsz77o7A4Sz3q9KwvP74tXlt6J4YyG8Pc3RpkC+OJOnTusNNHn/eoSWMNI9U
PG1dJ7pfzTx7K+yPdiBZ
=P3W5
-----END PGP SIGNATURE-----

--=-j3ieO0p3H8oxQ1Ut5b0B--
