From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: IAMT broken by commit 82776a4bcd7aa5fbcd2e6339b3ce88b727dd40ab
Date: Mon, 31 Jan 2011 15:24:16 -0800
Message-ID: <1296516256.3526.9.camel@jtkirshe-MOBL1>
References: <20100530010219.GA20368@volta.aurel32.net>
	 <8DD2590731AB5D4C9DBF71A877482A900118D29D0A@orsmsx509.amr.corp.intel.com>
	 <20110131114558.GA28303@volta.aurel32.net>
	 <20110131.123605.226778418.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-LiLHNlEuRW9p91T3RVOq"
Cc: "aurelien@aurel32.net" <aurelien@aurel32.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44678 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754117Ab1AaXYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 18:24:12 -0500
In-Reply-To: <20110131.123605.226778418.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LiLHNlEuRW9p91T3RVOq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-01-31 at 12:36 -0800, David Miller wrote:
> From: Aurelien Jarno <aurelien@aurel32.net>
> Date: Mon, 31 Jan 2011 12:45:58 +0100
>=20
> >> On recent kernels, IAMT support does not work after the machine has=
=20
> >> been powered-off. Even worse, it also goes into this state when I try
> >> to reboot it.
> >>=20
> >> I have done a bisect and got this commit:
> >>=20
> >> | commit 82776a4bcd7aa5fbcd2e6339b3ce88b727dd40ab
> >> | Author: Bruce Allan <bruce.w.allan@intel.com>
> >> | Date:   Fri Aug 14 14:35:33 2009 +0000
> >> |=20
> >> |     e1000e: WoL does not work on 82577/82578 with manageability enab=
led
> >> |    =20
> >> |     With manageability (Intel AMT) enabled via BIOS, PHY wakeup does=
 not get
> >> |     configured on newer parts which use PHY wakeup vs. MAC wakeup wh=
ich causes
> >> |     WoL to not work.  The driver should configure PHY wakeup whether=
 or not
> >> |     manageability is enabled.
> >> |    =20
> >> |     Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> >> |     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >> |     Signed-off-by: David S. Miller <davem@davemloft.net>
> >>=20
> >> I have tried to revert it on recent kernels (2.6.34), and IAMT is then
> >> working as expected. My machine is using a Gigabyte EQ45M-S2 motherboa=
rd
> >> with an 82567LM-3 ethernet chip (8086:10de), that is a different model
> >> than the one of the original problem.
> >>=20
> >> I do wonder if the changes in the patch should not only be done on som=
e=20
> >> chip models, and I will appreciate any help in fixing this issue.
> >>=20
> >=20
> > Just a short mail to say this problem is still present in 2.6.38-rc2.
> > The same solution still applies, that is reverting the above commit.
> > Note that reverting the first hunk only is enough to get it working
> > again.
>=20
> Intel folks please look into this.

We at looking into it, thanks.

--=-LiLHNlEuRW9p91T3RVOq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNR0SgAAoJECTsCADr/EWUcUwIAKvLY289jAVGzWFKFU/bDfom
VyqxlaydOxDF0l0G2Jo2sRl9TNnSmmhYoEAphJRaE8klEvmcfCaOtC/zobo8dbgg
PgkTjLqeoAtHqQq8KV1AK/eh6lcYH2eH7ZNVUQ01Z5mDNbLt+fu3uOEbuR7M0JjN
pEgS3eZkWdX7QoJlvVaQlGwAhiuMbjPfnDCXVMsLBqOBBQ3dLxHv6s1wUh8cdRgP
SNJ8/3yKTldGuhBl14e7A8Yq/MSeQj7flHlT5UaKjF8PjDsaEh8hM5TVL3x7xxQd
ofhhENgbTa/3s3eNOSGEQparDequnUYL7s3/S/1A/IlTC/nbygOEGI3ARMQsRJQ=
=QpHf
-----END PGP SIGNATURE-----

--=-LiLHNlEuRW9p91T3RVOq--

