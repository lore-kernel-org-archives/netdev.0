From: Harald Welte <laforge@netfilter.org>
Subject: Re: TX performance of Intel 82546
Date: Wed, 15 Sep 2004 19:55:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915175535.GA2678@sunbeam.de.gnumonks.org>
References: <20040915081439.GA27038@sunbeam.de.gnumonks.org> <414808F3.70104@draigBrady.com> <16712.14153.683690.710955@robur.slu.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jRHKVT23PllUwdXP"
Cc: P@draigBrady.com, Linux NICS <linux.nics@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16712.14153.683690.710955@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 15, 2004 at 02:36:25PM +0200, Robert Olsson wrote:

>  Chip should be able to transfer 64 packets in single burst I don't now
>  how set/verify this.

maybe this is what the E1000_TCTL_PBE flag in TXCTL and E1000_TBT
register are for?

I tried switching TCTL_PBE on, and played with different values of TBT
(0,1,255,65535) - however, no improvement in pps rate.

Maybe someone form intel could comment on this?

>  Cheers.
> 						--ro

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--jRHKVT23PllUwdXP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBSIIXXaXGVTD0i/8RAs2RAKCoE8oS1LIeP+AfwTHavKvrKs0/lACcCfEJ
cGKtceu8WBm1BgrYgB85lfc=
=Art0
-----END PGP SIGNATURE-----

--jRHKVT23PllUwdXP--
