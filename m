From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Update
Date: Thu, 09 Jun 2011 01:06:03 -0700
Message-ID: <1307606764.32044.24.camel@jtkirshe-mobl>
References: <1307605611.32044.16.camel@jtkirshe-mobl>
	 <20110609.005051.1530473933808285841.davem@davemloft.net>
	 <1307605995.32044.18.camel@jtkirshe-mobl>
	 <20110609.005821.841607202181194646.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-tZmXyxQnhzjP23u3jitR"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:22579 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757007Ab1FIIGE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 04:06:04 -0400
In-Reply-To: <20110609.005821.841607202181194646.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tZmXyxQnhzjP23u3jitR
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

Don't worry, I will be having a talk with validation, because my
understanding was that yes, we were doing allmodconfig compile testing
(along with several other's like allyesconfig and randomconfig).  I do a
sanity check compile before sending anything out, but my config just
makes sure that all the Intel LAN drivers (and DCB) are enabled.

--=-tZmXyxQnhzjP23u3jitR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEbBAABAgAGBQJN8H7rAAoJECTsCADr/EWUCGIH91yf/JgIfmcOvWbovEF4Ueiv
q7hElCiFWIP/gVB28w0inCNGT6J2m0V70d26mepVPxckpL0xnNPXltwkZB5VbxBZ
QB87Flz0i/8wuBJt1a9TgP4VKpqppNa9NpB1RNlJCs5IUm55l87UEhSW8vXMUNAI
SAapBsGQhUGnwq+7EVI4J+21/BJNU78QOS63zq/3bes8L+M2mBOzg/t7fzCVJ77A
1z7wmOX/rgftXfrqv2tHpTkMndnAVUqSt174pw12dSENSXpU0CrdrkHxfdnh20X+
nasyKfqJpNHYr3K48tRROqVmJXk7S3OgcHHCbHV2XoaK48lEqzkQ0nj2C1mjuw==
=iEhz
-----END PGP SIGNATURE-----

--=-tZmXyxQnhzjP23u3jitR--

