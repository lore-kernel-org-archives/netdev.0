From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Update
Date: Thu, 09 Jun 2011 01:14:27 -0700
Message-ID: <1307607268.32044.26.camel@jtkirshe-mobl>
References: <1307605611.32044.16.camel@jtkirshe-mobl>
	 <20110609.005051.1530473933808285841.davem@davemloft.net>
	 <1307605995.32044.18.camel@jtkirshe-mobl>
	 <20110609.005821.841607202181194646.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-lalUVulWrRGiXIrpQ9yF"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2875 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752879Ab1FIIOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 04:14:36 -0400
In-Reply-To: <20110609.005821.841607202181194646.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lalUVulWrRGiXIrpQ9yF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-06-09 at 00:58 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 09 Jun 2011 00:53:14 -0700
>=20
> > Just did, I saw that I did not have enabled and I got the same issue.  =
I
> > am looking into now, and will check to make sure there were no other
> > netlink_dump_start() references missed as well.
>=20
> Ummm, you're not doing "allmodconfig" builds for validation?
>=20
> I guarentee you have much more powerful computers than I do and I
> do allmodconfig/allyesconfig builds across the board during my work.
>=20
> And if you're touching global code, you should too :-)

Looks like after a thorough search, the infiniband instance was the only
instance missed.

--=-lalUVulWrRGiXIrpQ9yF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJN8IDjAAoJECTsCADr/EWUmS8IAKYvz6ZzeozsnCyA1hJp62h2
2RZCA+Iab1BiUrdrlQJoMTG/iWWe6GkWlUWpJuM/FE/Sv+PWsoLZ1OafOcg6xYRx
TPmGbM8Biv5ISzlRThsgRcvrUZEHnnl029o73XhxIlIqiJo50Crl7iL6Qzzy+XYR
LBYa6u8K9jacyu7o0Bq2R8XAqzYgBgfdW0KmUj7vPhAmREFZ7xD6XJsCvK1DoluA
gKG3mznbcXDYWHwuUIhSm8NmrDUslioaJRJlXhigRnFuEQ7toqrxbeGPjqfh0KYx
tPorIjjVV3jwPNzBBNdv86GYY20PhGf8xEpV0cgUV4k5UYDWviTwdcHxOD4sFpc=
=OE5V
-----END PGP SIGNATURE-----

--=-lalUVulWrRGiXIrpQ9yF--

