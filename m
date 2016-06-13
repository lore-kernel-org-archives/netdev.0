From: Leon Romanovsky <leon@kernel.org>
Subject: [GIT PULL] Please Pull Mellanox Shared Code
Date: Mon, 13 Jun 2016 15:03:01 +0300
Message-ID: <20160613120301.GF5408@leon.nu>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gdTfX7fkYsEEjebm"
Cc: RDMA mailing list <linux-rdma@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>, saeedm@mellanox.com
To: Doug Ledford <dledford@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:47738 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422972AbcFMMDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2016 08:03:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--gdTfX7fkYsEEjebm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Doug and David,

This is Mellanox mlx5_core shared code for both net-next and RDMA
trees for 4.8 kernel cycle.

This mlx5_ifc update introduces following ConnectX-4 features.

* netdev part:
 - MLX5_CQ_PERIOD_NUM_MODES for adaptive moderation support
 - QoS rate limiting
 - SQ context rate limiting
 - Auto negotiation fields in PTYS register
 - Source SQN field in flow table entry match structure
 - DCBX parameters

* RDMA part:
 - New XRQ opcodes, commands and capabilities layout
 - Extend Q counters definition to support IB.

Thank you,
  Saeed and Leon.

The following changes since commit af8c34ce6ae32addda3788d54a7e340cad22516b:

  Linux 4.7-rc2 (2016-06-05 14:31:26 -0700)

are available in the git repository at:

  git@gitolite.kernel.org:pub/scm/linux/kernel/git/leon/linux-rdma tags/shared

for you to fetch changes up to 7486216b3a0bd26375b17b2cc168a311106cea70:

  {net,IB}/mlx5: mlx5_ifc updates (2016-06-10 13:29:14 +0300)

----------------------------------------------------------------
Saeed Mahameed (1):
      {net,IB}/mlx5: mlx5_ifc updates

 include/linux/mlx5/mlx5_ifc.h | 275 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 263 insertions(+), 12 deletions(-)

--gdTfX7fkYsEEjebm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXXqD1AAoJEORje4g2clinFQwP/0A06YbTWh/q7Ti8DHpk1j4L
vgEVIxk5aLtPHAJ29Q7ctBGVN79kt/5gEoGhhRh0QNwVCHdbP3jLiufwSdS9J9aa
j50FbtyvlJbqS+15fFYMTk5XSqFp2gFxODm0YAP6viuGWxaYT1O6TD5ozynWS4Z1
/CKNDAOd0oHK/birU8i2/KdT/0uHcXs+MUsKgDAm4Hk/U3CHDB/Pp3XD40MZqaH+
79SzcRC8vSmo8aS0DU/sP68elLAyQX5y4atuHw7nDiyGfYgNsTC3UUZ96uFMyRaP
Z7EGUeUoUT2LulsSwWKSpwc1TT5YGbI8lGYi7ylG9vT6+Cw1U02LMK8hEYZ1SjhY
pAmGyuE/IA4+84rwS2jRobe/yuCwN0JOf2TG200rjAvzKKlOE5cKcE5omIAoOFB2
pngNBWGQ8+LZ2iM3NdJYUYmN53vs3ceP5JVGLa4zM7+xr3/5QPz67Na8Gfsez0fO
NcBJeAWwcgpYwu0FSvygdQA4kOT2LLCRFwbDQw0ocx4c0BoWsEUuhITbnThWe0u3
35glCpESprmG/gO2GT84qo+5YZvQCNu2SiNNa6AhmmI0ULWVRKIiFnf1z7uVdgbZ
gKXu79X4OYFgDQEeP327lLc0KNy8PCEgmZciHuMddOSqFYIFdunsMMSiv0QuBH0/
xFOmXxbN69jJ4k/XjhFJ
=BBpV
-----END PGP SIGNATURE-----

--gdTfX7fkYsEEjebm--
