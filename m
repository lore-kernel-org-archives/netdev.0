From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 4 Aug 2014 13:28:48 +1000
Message-ID: <20140804132848.0f3f9c7a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/CWUoYgNsN+rUWiyV+lV49Tc"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/CWUoYgNsN+rUWiyV+lV49Tc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv6/sysctl_net_ipv6.c between commit 166bd890a3d8 ("ipv6: data of
fwmark_reflect sysctl needs to be updated on netns construction") from
the net tree and commit cb1ce2ef387b ("ipv6: Implement automatic flow
label generation on transmit") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv6/sysctl_net_ipv6.c
index 818334619abb,5bf7b61f8ae8..000000000000
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@@ -74,7 -81,7 +81,8 @@@ static int __net_init ipv6_sysctl_net_i
  	ipv6_table[0].data =3D &net->ipv6.sysctl.bindv6only;
  	ipv6_table[1].data =3D &net->ipv6.sysctl.anycast_src_echo_reply;
  	ipv6_table[2].data =3D &net->ipv6.sysctl.flowlabel_consistency;
- 	ipv6_table[3].data =3D &net->ipv6.sysctl.fwmark_reflect;
+ 	ipv6_table[3].data =3D &net->ipv6.sysctl.auto_flowlabels;
++	ipv6_table[4].data =3D &net->ipv6.sysctl.fwmark_reflect;
 =20
  	ipv6_route_table =3D ipv6_route_sysctl_init(net);
  	if (!ipv6_route_table)

--Sig_/CWUoYgNsN+rUWiyV+lV49Tc
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJT3v30AAoJEMDTa8Ir7ZwVHVsP/3mXMQ/JDNVtssuT5cRvQwun
HU0U9Drr38U/L0VU9smyoRGjLza971eC2gh7YQs51HmTKWguj9opjJReg0594f+h
yO5j9b7KTq0lMNnOFjTWeTRoqk88uuATdCdUU5wfOD1BTPayuTlxbjOEBp2woHvV
SnxV0m857mH47zE8v5wHR8XH9GgD+mneKvLbb3DAe7UWfC1JiV3WKz3OlNtG6Pbf
ubfnwxVibJMw979rZTlQ2/PjkDHGYhhoJB/8wy1j+PmDJvuPCv7Ty3r2t+vUFfGp
3xXIOn+Cey6u54LBkyPeJ40UF62ymIa7QpQvJ8ahyAWBqhhSjaW3ax8f20Orgtpe
LUD+jmquNw0FVEJc8gZST/RGxqVFNUs17cUXxZ6TSftKJv5N9jul0kAkHic5mrNb
/4YPGj5PKSw78yhlpV7pvcifheoV2fJFhBGNWDoh9ElzKiaDbVgJdxn7cmzeeuXq
10Uyuo8+IS7RYNsHBcKmVfQC5A8ZpwCLN/HIB55VZIKYT59LVcfReL6KmtCMBoFv
JARCgvQY2Jb1JbizCCgQ3XCEy/IWttju/69VK36+c9yQOm/trnqkCPyQ+e+BK0rD
9p5Zl4EN7jbnGQg/4Iljr9KJvjujrPlimbpQLoC92JWdO/JB8SCDaao1rKvlkmYM
UxK0K+YtJWYWIzbRA99z
=WrGb
-----END PGP SIGNATURE-----

--Sig_/CWUoYgNsN+rUWiyV+lV49Tc--
