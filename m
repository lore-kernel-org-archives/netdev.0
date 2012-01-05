From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the selinux tree with the net-next tree
Date: Thu, 5 Jan 2012 15:12:55 +1100
Message-ID: <20120105151255.f72ad113a93493bb55844034@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__5_Jan_2012_15_12_55_+1100_XqbFSQ8c0xC3wtmn"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Paul Moore <pmoore@redhat.com>,
	Andrei Emeltchenko <andrei.emeltchenko@intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__5_Jan_2012_15_12_55_+1100_XqbFSQ8c0xC3wtmn
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Eric,

Today's linux-next merge of the selinux tree got a conflict in
net/bluetooth/l2cap_sock.c between commit 15770b1ab974 ("Bluetooth:
convert force_active variable to flag in l2cap chan") from the net-next
tree and commit 53860f3d0499 ("bluetooth: Properly clone LSM attributes
to newly created child connections") from the selinux tree.

These both remove the same line, but there is probably something more
subtle going on ...  I just used the version from the net-next tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__5_Jan_2012_15_12_55_+1100_XqbFSQ8c0xC3wtmn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPBSNHAAoJEECxmPOUX5FEIVwQAJJ8sdp0xqjn4SSb5NtmGCJe
5DgScWoCvCc8ymNw7b8SruzE+wEjnVaH6DjtymIs8Z863y7ff+21/IcVQYcGElgL
2E4TJu6zG6WYx8i9L3BFrr+AgPKpCrT90MzDqzfJI0ZewmeWU8ZS+nrXV2n82WgK
3clOdzhpdEhQt9Ibm6ZOoecN4ylHg9NhspjJq0uHdQIOr4aiPwOfXAzDq6MBMSu9
YZVv/gtVtdfEFKVNhZjy+n8ba5MWbuR8j68H1HLh/798+KwBCg3rfeojAEpp4y7t
DjxN2wrdDv0LYRSxVU9dQd4lx8I4umSVSPVLS2roKH1KMgdcsGuyMv5dbaKsRNK+
8DrZT+HphnPApD3CgmR1MB7f1N4OY0QydUxgVU6i8Wvzgd1G+uAzMYIn/U+zjhpp
RIubh9vWuDVd1IIUXcV3fptOjFWT5wGc0TxHn9DTuaUs/ZS2QfG+tOuodVP3EIQ8
h/FM67su0W4YDmjmAXgLAHGKMxqFhcQpciXYw5L0FDOmrQ9MV+j5d48NppBIZ8yl
KCYb193Pg4tcPueCAU1RExJDSkz2TnPK98NI+UU+nOxP4DfjkWLzuGHLLxkpzaGu
yBIQ1V1pOCwMJ2uU1ybn8pMbhfQ/q+2q90rMRrnVMdEfm5OXcay6kb52PokQZasf
6RaRzsdZ+7dWHyJHfywA
=8Tue
-----END PGP SIGNATURE-----

--Signature=_Thu__5_Jan_2012_15_12_55_+1100_XqbFSQ8c0xC3wtmn--
