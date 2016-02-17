From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V5 5/8] net/ethtool: support set coalesce per queue
Date: Wed, 17 Feb 2016 01:00:26 +0000
Message-ID: <1455670826.1143.20.camel@decadent.org.uk>
References: <1455625964-8943-1-git-send-email-kan.liang@intel.com>
	 <1455625964-8943-6-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Nxndir5sDflXBNlZTQTu"
Cc: andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, decot@googlers.com
To: Kan Liang <kan.liang@intel.com>, netdev@vger.kernel.org,
	davem@davemloft.net, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46802 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964874AbcBQBAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 20:00:33 -0500
In-Reply-To: <1455625964-8943-6-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Nxndir5sDflXBNlZTQTu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-02-16 at 07:32 -0500, Kan Liang wrote:
> From: Kan Liang <kan.liang@intel.com>
>=20
> This patch implements sub command ETHTOOL_SCOALESCE for ioctl
> ETHTOOL_PERQUEUE. It introduces an interface set_per_queue_coalesce to
> set coalesce of each masked queue to device driver. The wanted coalesce
> information are stored in "data" for each masked queue, which can copy
> from userspace.
> If it fails to set coalesce to device driver, the value which already
> set to specific queue will be tried to rollback.
>=20
> Signed-off-by: Kan Liang <kan.liang@intel.com>
[...]

Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.
--=-Nxndir5sDflXBNlZTQTu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsPGKue/yOyVhhEJAQoh4hAAs+AGb9I47TsS3BYuEF5RzErtY6WylMQz
u8etuI5ZVFqkpC2sOuGQiTL18rfGNUexwebmBV8JY7RydhDx/Bi1gkb6XgydOW0h
DBUxc62IDHHuj2SUrLkeMNoeHe/Tc1u8ilzc0K/K9uJZv/g/8I4UwfzNtwwxcTjH
vOjU0tCb7886zA2RvaWWJQJcdRbohmTE589RXgCEmsgZEhd8ak0cgtdF3kgyvjiq
Uad+Nbnu+ZloQ6vVfd+3SueYUCxwCKdJNZhuS8DsRKCaKXyByZqnJTs9NT9aORWQ
ZnAjHWAZ5sh4AS2e07LWr51a0OQxOF9CUYWD3PtpEUcc7r4e+vv34YuiPKL2ECYk
1zjjVyiqCwdyQNn5PS3gjCXEioTDMALZI53sezT3dTztLHLVFUIOWkdWAu7TXBPN
o53LY++uyYk8FxtMmGkL68UA2Im92H2Z2xYgSjUGRTUd+JCmb5g+gqaQcpMMxQkz
tvIwitz/1/xyG4cOcmheg8KFDo9KQdy/vZD2rH68AEwp1jEHsLEECb95CvXliEN4
/dKjKR/p1Lq/1uHFp8AsuE7bAyCHNyGIBLUMWtv85TqWq1iBzqEHJpta0bNFAsPz
3SF2dFXrPyakLtaBqpWAveq85VbcqzmztWovnVuTRBcJmxyYrMDqeRmDE9Tv02Uk
vszR6BoO5GU=
=kD+4
-----END PGP SIGNATURE-----

--=-Nxndir5sDflXBNlZTQTu--
