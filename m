From: Dax Kelson <Dax@GuruLabs.com>
Subject: echo 0 > send_redirects broken?
Date: Thu, 04 Sep 2003 15:04:02 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1062709441.2884.34.camel@mentor.gurulabs.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-cIOIRamT7qY1i+wP+ewE"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-cIOIRamT7qY1i+wP+ewE
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

192.168.0.0/24=20

  .9    .10      .254
=3D=3D|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D
 [A]    [B]   [Router]

Hosts A and B running RHL9 with kernel 2.4.20-8.

1. Start pinging the .254 IP from host A

2. Enable ip_forwarding on host B
3. Run arpspoof on host B to poison the arp cache on host A and the
router
4. On host B Turn off icmp redirects with the command:

echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects

Problem: Host B *still* sends ICMP redirects. Initially many redirects
are sent, then the rate at which ICMP redirects are sent slows down
until redirects only trickle out every few minutes.

In older 2.4 kernels (2.4.9 for example) this did not happen. Turning
off ICMP redirects really turned them off.

Comments?

--=-cIOIRamT7qY1i+wP+ewE
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQA/V6jBESq34TbtkiIRAtS0AJ9QnqGym/Ajz1HFOZ3qXQe8xRZuRQCgqPrC
Ot1mGFrtzv56rD7xmEriKGM=
=GT1y
-----END PGP SIGNATURE-----

--=-cIOIRamT7qY1i+wP+ewE--
