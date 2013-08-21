From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the trivial tree with the net-next tree
Date: Wed, 21 Aug 2013 14:17:15 +1000
Message-ID: <20130821141715.a1b18a28965e341531775656@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__21_Aug_2013_14_17_15_+1000_Yu.tMxvqGDXj4q8M"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Masanari Iida <standby24x7@gmail.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__21_Aug_2013_14_17_15_+1000_Yu.tMxvqGDXj4q8M
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jiri,

Today's linux-next merge of the trivial tree got a conflict in
drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c between commit
068a8d197e00 ("qlcnic: Replace poll mode mailbox interface with interrupt
based mailbox interface") from the  tree and commit 0b1587b18bfe
("treewide: Fix typo in printk") from the trivial tree.

I fixed it up (the former removed the line fixed by the latter, so I used
that) and can carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__21_Aug_2013_14_17_15_+1000_Yu.tMxvqGDXj4q8M
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSFD9LAAoJEECxmPOUX5FE6NIP/Rp0WZ+gNRLq4BTRU+bRk7Vu
3A9p3UumTbDR+4O+8PE1NUVvu2mC29FXdVeZpKggzcS1J2dbc2j+3KpUGjS1yy3l
+AsW3MYFiRxO5+dM8k4BcGbcE8E+83bH9xCI/saHFR7VoV8mod8BUQwLoqkKGTYW
yJQdCsnYr3aEUbj+nJkOSO97iY83qUangtERX37gxATLguER+Wabtha0RZm/Tmio
W7tIc7Suemwqcca4wGW9P/EvYPPaQSqceTP92YtgWQWOzSdO/Nzfpga1SrBvGha0
Fp2EbyMQhpQVZK0G/dSqVuYDB0Ee1drLrhSSZDsT1BiAdKm6aeWGPNiXYBoyq2Ye
DeOSOHD6wNxB5Rqdl5fQkMTDT6ivq2LVjonrDJAFqaNV2yBsJ3TlPVPSmIB+/wLA
2ixeKE1nk3WoYuT9gu4mSh3tV1wTU/IoxAA3+VwKrOuOmWb+qpAv7mh4inDkhtBn
4BK5PPSyeBzlOOfiwWDLO7jn5dx3ceg6t3ugudO9eZKNidy7waoheN27vPV8EO4t
yUWTKG+Zmpris3AQV+R2ZJbcgNGGm1mwjBU4kTMOtK9hYeJXE/mCdSvHLrXwhV7i
qzyCsnqAt7sIjmqh5MqINRUZxRtGR8KSOtqdfw4dNKBppx8B4LkrhFco/pIB1jxt
vOFUYblOsORTtYHF7H6u
=t1XW
-----END PGP SIGNATURE-----

--Signature=_Wed__21_Aug_2013_14_17_15_+1000_Yu.tMxvqGDXj4q8M--
