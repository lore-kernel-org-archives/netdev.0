From: William Dauchy <william@gandi.net>
Subject: Re: [Intel-wired-lan] regression in ixgbe SFP detection patch
Date: Thu, 12 Nov 2015 13:22:57 +0100
Message-ID: <20151112122257.GE3641@gandi.net>
References: <20151111173527.GA3641@gandi.net>
 <87618083B2453E4A8714035B62D67992504DF0AA@FMSMSX105.amr.corp.intel.com>
 <424516AF-C3E7-4D00-8889-ED7EA8EF315E@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MIdTMoZhcV1D07fI"
Cc: William Dauchy <william@gandi.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:52350 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754489AbbKLMXA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2015 07:23:00 -0500
Content-Disposition: inline
In-Reply-To: <424516AF-C3E7-4D00-8889-ED7EA8EF315E@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MIdTMoZhcV1D07fI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Nov11 22:13, Rustad, Mark D wrote:
> Just so you know, there are patches in queue that will improve this situa=
tion in two ways:
> 1) When the I2C probe times out, the code assumes that the cage is empty =
and does not retry the access until the next probe.
> 2) The driver will use its own private workqueue, so it will not affect t=
he system workqueues at all.

Thanks guys for the details,  I will have a look.
--=20
William

--MIdTMoZhcV1D07fI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlZEhKEACgkQ1I6eqOUidQHpGgCghjBQ5/6bmlinp4C6Ah+B+zw6
lGQAn1w1LxEInaoNK01/+6ZRNOlWt4Kx
=wcNA
-----END PGP SIGNATURE-----

--MIdTMoZhcV1D07fI--
