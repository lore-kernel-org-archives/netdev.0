From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Fri, 19 Nov 2010 11:17:06 +1100
Message-ID: <20101119111706.d68efe13.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__19_Nov_2010_11_17_06_+1100_Ui4wnqUT.D8CWZp."
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:49814 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761085Ab0KSARL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 19:17:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__19_Nov_2010_11_17_06_+1100_Ui4wnqUT.D8CWZp.
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/bonding/bond_main.c between commit
3006bc38895895f1a0352c2e17e1a503f35f7e2f ("bonding: fix a race in IGMP
handling") from the net-current tree and commit
866f3b25a2eb60d7529c227a0ecd80c3aba443fd ("bonding: IGMP handling
cleanup") from the net tree.

I just assumed that the latter is a better solution and used that.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__19_Nov_2010_11_17_06_+1100_Ui4wnqUT.D8CWZp.
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJM5cICAAoJEDMEi1NhKgbsDsIH/1Ihxu2nPY3UycvyKURjB792
4cer2c7DyqibH5ELhzvy0BE3C94m/H75nhz8zBYbv4lb3P8kI9KPVFg+2qPUk3Aw
8nx2Keb9RqDUhNVqlyQLef/ey6+upTkR3Xt2HjAZe2AH8XQEl5hCXDzbX/IbmvoF
BCSNZJSDDJBIcIXVpkFoT78xByeVM18sMEE/oQKNATpSE2eXslwU8iXyMqp42F/X
el+GuV0xuMA7H9y/VU5r8yBn8DpkKduvrKevzGRZsxP+vwUHaAgoGmEjyl0zgDuz
hCVsFjs4MqMWL4kl5WkxzBAvpZ4CGZ0vPI+4zOZvW6ci9nv1YN49j7biUZoZHos=
=8WSp
-----END PGP SIGNATURE-----

--Signature=_Fri__19_Nov_2010_11_17_06_+1100_Ui4wnqUT.D8CWZp.--
