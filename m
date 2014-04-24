From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 24 Apr 2014 11:47:26 +1000
Message-ID: <20140424114726.07876050b5b805463a085191@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__24_Apr_2014_11_47_26_+1000_Fv4_xzF7KW41M1Jh"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jakub Kicinski <kubakici@wp.pl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__24_Apr_2014_11_47_26_+1000_Fv4_xzF7KW41M1Jh
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/intel/igb/e1000_mac.c between commit c5ffe7e1f745
("e1000e/igb/ixgbe/i40e: fix message terminations") from the net tree and
commit c75c4edfc38d ("igb: Cleanups for messaging") from the net-next
tree.

I fixed it up (the former was a superset of the latter) and can carry the
fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__24_Apr_2014_11_47_26_+1000_Fv4_xzF7KW41M1Jh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTWG0zAAoJEMDTa8Ir7ZwVvLkP/1Ry/p/p9Gcy+juyMgEyQNIZ
5Y3TcJiuDrxqHki09tnGsPiMtxjKOU3cUWe8FGF0O/vk30/Du+n1up8rjpMrPGvS
dhXrxw4dp9YocNCO5Y1DlnfkcdY0NtYplWNU6XKh+VGMOH3YpKUl4zKPSyQXslt5
eU20ajz73KdLqdd/++Aj7qXcNVb1imr0Bg3pUrLE8sLMQlsGxYZhrL6pqx1+VrW1
Br1g1L+lTrMbDz6tvJBjDJ7iFujZLlB9kv7tS66XqesAHxDCqSXpeYO79YYZOoaI
8Jw6gSk1DVRkxKwG6dm4VrMbihJcsYyYgX6lG1BAhqrBy0PaML2A4okt6+tSdbPE
6uQSU+HgaABOmSVvqyoBdE76CkQ9C/Is6jw2/ZlgQVGmJmkDwLkC2k26VSQP7lBh
Te1q8lvQXpvC5cASYMdJr5APwhAU72ztlEyY7ps/c8PGyiha+zbaGgWnrtOmkjEm
geO2RJG5YJDxpcNBgRInNV7BU8F0e9X3H+8sViu49PE9TunIcFX5IBdRA6Q40yx+
e4hC7o1z3HOmQSH1YRAnUr5kkiVJ0W6C5sFkfPYvUjg02WUlrPyC4gPsbBI5/nN5
MiiW3Vv4wL4AnFqfNkZiiseFiqe8X+dPMH5Ew6adm2MXzc7XOWrhQ9MUKKGdPpZn
nOWk+ODLOFUPJV3MJps0
=ygbA
-----END PGP SIGNATURE-----

--Signature=_Thu__24_Apr_2014_11_47_26_+1000_Fv4_xzF7KW41M1Jh--
