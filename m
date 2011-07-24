From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Linux Kernel | Intel Driver Bug - please update
Date: Sun, 24 Jul 2011 15:47:17 -0700
Message-ID: <1311547638.2835.72.camel@jtkirshe-mobl>
References: <0BE7A0BD7DFE4537AA0C03E333326E52@NOTENIKO>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-h4jpPqPBg2yq49W6NmJ0"
Cc: "kristoffer@gaisler.com" <kristoffer@gaisler.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>, support@localhost.net.ar,
	netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Nicol=E1s?= Sigal | LocalHost Soluciones
	 Innovadoras <nicolas.sigal@localhost.net.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46238 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503Ab1GXWrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jul 2011 18:47:19 -0400
In-Reply-To: <0BE7A0BD7DFE4537AA0C03E333326E52@NOTENIKO>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-h4jpPqPBg2yq49W6NmJ0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-07-24 at 13:28 -0700, Nicol=C3=A1s Sigal | LocalHost Solucione=
s
Innovadoras wrote:
> Please, can you update the e1000e driver of the kernel to v1.4.4?
> =20
> http://downloadcenter.intel.com/Detail_Desc.aspx?agr=3DY&ProdId=3D3299&Dw=
nldID=3D15817&ProductFamily=3DComponentes+Ethernet&ProductLine=3DControlado=
res+Ethernet&ProductProduct=3DControlador+Intel%C2%AE+82579+Gigabit+Etherne=
t&DownloadType=3DControladoresspa
> =20
> This version have an important bug fixed:
> * 82579: Fix for Tx Hang on FTS ME Platform
>=20
> And we have this problem in all of our servers with this NIC and ME
> on.
> =20
> Debug:
> =20
> Jul 24 14:23:27 [kernel] e1000e 0000:00:19.0: eth0: Detected Hardware
> Unit Hang:
> Jul 24 14:23:27 [kernel]   TDH                  <0>
> Jul 24 14:23:27 [kernel]   TDT                  <16>
> Jul 24 14:23:27 [kernel]   next_to_use          <16>
> Jul 24 14:23:27 [kernel]   next_to_clean        <0>
> Jul 24 14:23:27 [kernel] buffer_info[next_to_clean]:
> Jul 24 14:23:27 [kernel]   time_stamp           <10282156f>
> Jul 24 14:23:27 [kernel]   next_to_watch        <0>
> Jul 24 14:23:27 [kernel]   jiffies              <102821aed>
> Jul 24 14:23:27 [kernel]   next_to_watch.status <0>
> Jul 24 14:23:27 [kernel] MAC Status             <80143>
> Jul 24 14:23:27 [kernel] PHY Status             <796d>
> Jul 24 14:23:27 [kernel] PHY 1000BASE-T Status  <0>
> Jul 24 14:23:27 [kernel] PHY Extended Status    <3000>
> Jul 24 14:23:27 [kernel] PCI Status             <10>
> Jul 24 14:23:28 [kernel] e1000e 0000:00:19.0: eth0: Reset adapter
> Jul 24 14:23:30 [kernel] e1000e: eth0 NIC Link is Up 100 Mbps Full
> Duplex, Flow Control: Rx/Tx
> Jul 24 14:23:30 [kernel] e1000e 0000:00:19.0: eth0: 10/100 speed:
> disabling TSO
> =20


[removed ixgbe/igb Intel maintainers, and Linus from the email thread]
Added a more appropriate mailing list (netdev)

We currently have the kernel patches in review and testing to update the
e1000e driver to v1.4.4.  I should be able to push some, if not all of
the changes upstream later this week.

--=-h4jpPqPBg2yq49W6NmJ0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOLKD1AAoJECTsCADr/EWUsY8H/RnxaTsPAZRxrcYQUKxeUCJX
Ktl91Ic8ZsjC2JlyM+22wucP5gmSmXZz6p8bfMCQzWWOeyXDN7fH5TyTKmnzYoda
FwFFK9pSDlroPi/Eh3EtLwbodyqaZtKLp3tAw83ciSnzlYv+Un/WU8yASb8qZwlE
7qgv9K0R4eAK7Vvtr58nq+BkP2W2LGJgIgUP0CwjC57DIbJAC1KwMlJrInNRfZ8y
oDjwXEXZ6NIjnuUBcZzKdVYZCqibATRIQ6Wkpk2efPPGSzTLcR44Bt9VpMPlCe5z
ntN3DxnVypok77iI35bixBjKs9ts1EqKoQWFHJqsxnih2rBxhd/tYws7gWcBIvg=
=ylx1
-----END PGP SIGNATURE-----

--=-h4jpPqPBg2yq49W6NmJ0--

