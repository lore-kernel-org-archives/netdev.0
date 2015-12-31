From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/1] ixgbe: synchronize link_up and link_speed of a
 slave interface
Date: Wed, 30 Dec 2015 21:37:48 -0800
Message-ID: <1451540268.3348.108.camel@intel.com>
References: <7EED4F91-2DE5-407F-BA6A-681ED57650E4@intel.com>
	 <1451538295-15823-1-git-send-email-zyjzyj2000@gmail.com>
	 <1451538295-15823-2-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1R2gjjA+h5mDJn73oqGR"
Cc: venkat.viswanathan@windriver.com, Boris.Shteinbock@windriver.com,
	Vincent.Bourg@windriver.com
To: zyjzyj2000@gmail.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, mark.d.rustad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:57434 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751509AbbLaFhx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Dec 2015 00:37:53 -0500
In-Reply-To: <1451538295-15823-2-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1R2gjjA+h5mDJn73oqGR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-12-31 at 13:04 +0800, zyjzyj2000@gmail.com wrote:
> From: Zhu Yanjun <yanjun.zhu@windriver.com>
>=20
> According to the suggestions from Rustad, Mark D, to all the slave=C2=A0
> interfaces, the link_speed and link_up should be synchronized since
> the time span between link_up and link_speed will make some virtual
> NICs not work well, such as a bonding driver in 802.3ad mode.
>=20
> Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
> ---

Since this is version 5 of your original patch, you should be putting
the change log of this patch here, so that we can follow how you got to
this point. =C2=A0This helpful for the reviewers (and me, the maintainer).
=C2=A0For example:
v2: dropped the "else" case of "if" statement, based on feedback from
=C2=A0 =C2=A0 Jeff Kirsher
v3: changed the if statement to simply return when the link speed is
=C2=A0 =C2=A0 unknown on X540 parts based on feedback from Emil Tantilov
v4: updated code comment and if statement to test for IFF_SLAVE flag
V5: simplified code comment and if statement to only test for IFF_SLAVE
=C2=A0 =C2=A0 flag and unknown link speed.

Of course, you can expand on what I have above, I just did a quick
summary of the changes as an example of a change log.=C2=A0

> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 5 +++++
> =C2=A01 file changed, 5 insertions(+)

--=-1R2gjjA+h5mDJn73oqGR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWhL8sAAoJEOVv75VaS+3OVIIQAIfBNN4UwQiYalfHqxEJ81UD
NDJQjeZj7GKYfH3eQaGs/vE041Fk4+xYaYYwUqRKHqIO2mN4VgjQCaCNaR8Qq9b8
K20549exdXN8YK5D7E0b4Sy2rtGtdkVT/Mq5oLin8Yr3iYIgLRAR1PIfR218HIGP
Eu4kEjKia5KAT/slMGu2PybkNvqbuHWmYeeZonX2z6V2MINq7Lz0zf4BZhYcM/ji
tHLsFa9AmpiMkTFW1DNyeIazwzmCOT859wduped+gazW2Rw23udR43vV1iyftoHM
poASkw+FgjZl68GbWyMsco5D0qBr7BO14XtwW8gyh9zP0o/493ukWOhesoJynC+V
6t0JKpNNJPxhMnREoIMtHy0LpBHgq2DSkXzjtCJNSoFtce2hn6aRLnFKgVnfY/Bf
ZZwv8VP/svXCCczK7BIC4whaAB7x6lNngWQL0Plq7yZNjXjHpgIizROhReNVZMQi
XTHf4s1QCCtUhX5g2Dik0XcapxnPMG9Orkpz4H0400cUN+ll2Hz27eEGg2tSa/M5
cbGOrbgdCGKWVTq1JykM8SH13tk5Wny12KJ+zsWyi6Gm5crmBSHUdFxs1zmylMfi
e7EaiG5eaNRfBnjKCajpSI1bdpglMAgFj6hHFfvkJvPVYXOH3/sahVi8nJ/q12td
nRnlunh7NB/9Bvh0737d
=09/N
-----END PGP SIGNATURE-----

--=-1R2gjjA+h5mDJn73oqGR--
