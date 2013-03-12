From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Tue, 12 Mar 2013 11:33:20 +1100
Message-ID: <20130312113320.b1f41dcb59baa74a51b064cc@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__12_Mar_2013_11_33_20_+1100_9XMUROop0z_8UXdM"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Konstantin Khlebnikov <khlebnikov@openvz.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__12_Mar_2013_11_33_20_+1100_9XMUROop0z_8UXdM
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/intel/e1000e/netdev.c between commits 4e0855dff094
("e1000e: fix pci-device enable-counter balance") and 66148babe728
("e1000e: fix runtime power management transitions") from Linus' tree and
commit f0ff439872e1 ("e1000e: cleanup CODE_INDENT checkpatch errors")
from the net-next tree.

The former removed the line fixed by the latter, so I did that and can
carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__12_Mar_2013_11_33_20_+1100_9XMUROop0z_8UXdM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRPnfQAAoJEECxmPOUX5FEQIUP/At6swZienJ8i92Y53y8t1t8
tk/KsdXyZnopaH4NvUdyan4Q0BV39A9h3Mf8QBgA7m+spqSrwtrNivA9N3/CACnL
3XC71EywF1n4NtUPgEqxJNYBrYr9NN1DXwagDzsivP6HE4p2C001rB47lkqIV1QQ
y6NMBtZtwWDqlac8+m8phwKUDTW3D+c2OH2WCWaKUwc0NaDhm9NUD3F+7rr0j0pB
TWu8FJ1sbVibxQ3KMaF+qBKQ6ZVS9NJKUAz/6e3VlUnJMQ7d/mBdq8lFTvHqFWuG
wQ7BPGmeZkjMpSg3M4KbcxajFHvl5lLpxndhaYMKh76/Caz0Jy6NCLuyQoXql300
M4wfHxj3cw8MJZxu74xK3wj8sgc40xYiGYO3+n9f2eXltAi0tsH7lJzWlAHO9ZrE
C4DmzviahEgzwgq6/Wk/onnhMk0zHWa7EHwRnxKkS9BZjRy5vgCkcT3YuuZrxPoc
Jar3CBmnKzLu+uQXhW4UNf9HQHHbY81BL2bnFanbnOrD5RQWEJPEwoDmUKSKOent
NdNN4TZg5y0vCHqC7pnxQGVTwONOJqaa6CTMzbBAQQgas3WiUAjD2XlfRxty0dsS
pW9ncF/Qy0eHN/DmWetjKMOOnPjprl7eDizUIVHj0LhI3iS3zuj3urFlj/rlClXW
Z1xvSyASMA00L/U6Xvfx
=Thrz
-----END PGP SIGNATURE-----

--Signature=_Tue__12_Mar_2013_11_33_20_+1100_9XMUROop0z_8UXdM--
