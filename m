From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net 0/2] drivers/net,ipv6: Fix IPv6 fragment ID selection
	for virtio
Date: Mon, 27 Oct 2014 04:17:05 +0000
Message-ID: <1414383425.16849.18.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7302440463469595550=="
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============7302440463469595550==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-q/gdOX8iirg2wKBOuEKH"


--=-q/gdOX8iirg2wKBOuEKH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The virtio net protocol supports UFO but does not provide for passing a
fragment ID for fragmentation of IPv6 packets.  We used to generate a
fragment ID wherever such a packet was fragmented, but currently we
always use ID=3D0!

Ben.

Ben Hutchings (2):
  drivers/net: Disable UFO through virtio
  drivers/net,ipv6: Select IPv6 fragment idents for virtio UFO packets

 drivers/net/macvtap.c    | 16 ++++++++--------
 drivers/net/tun.c        | 24 +++++++++++++++---------
 drivers/net/virtio_net.c | 23 +++++++++++++----------
 include/net/ipv6.h       |  2 ++
 net/ipv6/output_core.c   | 34 ++++++++++++++++++++++++++++++++++
 5 files changed, 72 insertions(+), 27 deletions(-)


--=20
Ben Hutchings
Theory and practice are closer in theory than in practice.
                                - John Levine, moderator of comp.compilers

--=-q/gdOX8iirg2wKBOuEKH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVE3HR+e/yOyVhhEJAQoFwRAAhBGvGJv1nXjnptd8jtj36hrNSMSfowUj
hkialXzsmw8J36tbujpj6HiQjD+wrkwjgiMPSkSxlWJrCYjn0vb25dcz/KHLecAc
htavJ6kPw6J7cAcHXvr4PUNo2nGcVY2JHcWRkTF2ad3v4kQ+Ko5Q9+b50Xir0nAV
DxlrfaTI5ewHO8jRnXU7cC1Qp8M3WX1/5Jrs+4ZpOa36XhjX8OiGiMvn0XjbCEQt
y2JLBjneHKjC6/RXQ6W/3D7sRr+0sxSIch81Ck2Je3hkWHPUarckf6Yg/AATUyRs
8DodRU691NPEK55l8iZdfCYwTc/Xb06aOJgQnzZeezXL0hQrMLhz/1gYVgqMIIau
Zydfoy5mxTUPBYnbTtA48tOWPhf85w5sjoOVkyh7XBriBPRH0Z8nlUfD782Egs40
5xhi8v+np0O6dOzYCiRG8X+J/w9drtATjcc15TuDXIw3KOHg78MQUoUa4IKO1j6o
mSy+uPyZ47aHGMCvEE1HuCgyzPjXad+qq8mqm0sBhJwpjkLV1Nqb3LXcXbrwPcwM
KIhqaUpkTsBm0GP1mi8fT+ljIyyTLfAqfE9qNrcyOHGakL66epQdHTKiBA/VcUix
wEt91gelzcpIOswE08D8X5+6vuhMh7rTpZ83tNAuL0MT+Uk0g7vDQbPfstqbYJEm
OZMHhcjojy8=
=C2pj
-----END PGP SIGNATURE-----

--=-q/gdOX8iirg2wKBOuEKH--

--===============7302440463469595550==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============7302440463469595550==--
