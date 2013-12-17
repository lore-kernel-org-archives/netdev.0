From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning in Linus' tree
Date: Wed, 18 Dec 2013 09:52:03 +1100
Message-ID: <20131218095203.aceb7cfffffa16907feb9af7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__18_Dec_2013_09_52_03_+1100_u6ymJkaAjEug80Fh"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__18_Dec_2013_09_52_03_+1100_u6ymJkaAjEug80Fh
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

While building Linus' tree, today's linux-next build (powerpc
ppc64_defconfig) produced this warning:

drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c: In function 'ixgbe_pci_srio=
v_disable':
drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c:294:6: warning: unused varia=
ble 'current_flags' [-Wunused-variable]
  u32 current_flags =3D adapter->flags;
      ^

Introduced by commit 2a47fa45d4df ("ixgbe: enable l2 forwarding
acceleration for macvlans") which was merged before v3.13-rc1.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__18_Dec_2013_09_52_03_+1100_u6ymJkaAjEug80Fh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSsNWXAAoJEMDTa8Ir7ZwVJvQQAJMlqkwq6m8iUu+XT3Scrw6l
RzOUPvbvlIk5T0ojg5YL+j4lK5n+M71wsud9vDTNQCQvXGt92+oqmwJX0s7AY76c
khaOHGkP9Fie4wiLlZLYE8CybYtUQLizTPxqxlQOz7cUM9THUX+yZ74IInYc0tE3
pUwRAegvRi8JVrVUNOvBBC4CkY9SOF/vsHYVfsJBFR2VKUcfWL2m9UODa8Ih7k8i
Jw36z1mHa5mvP+KHgOM6rUvWV6KrjetrbKkgFkFeWf/5CUhjiZz4PteQqdk7wH+Y
bTQM/MO35UoBgJYUmLT6yZESu8BsPBAwbOaTq3FFuI940m2c+wugNl0BTLvSkPFy
BKWKJxKS+5KcN6M4uVDOxNEDFL1xoMMX1glT9qDSqXOrrUw18OSWxqQc2Wg++bbw
pLF+DB0eOqDqNTzIfQehCLHbPgVdUyRBNvx7m8swrTFRS1IxMszl/zE5MQgykZ5u
OP1zjF0Fg+1YKum8SqK1TC8YImAvNTrTKr/GfMsPHkya0/4fBOdeTJWVKLFJcEyC
P22f7D3SnxEX0s8yoCPlQPZ5/Un7NZSn7NMOfw9QZvtPAI13FZdlmUofXZ+5ePvb
l8tngQgpN5CBfHeiR2psgCaL5BPAMRgXLbvybNjKHTAkPvG/yYX1RlzWiybds3IV
vQKfUVa9GphqfxQsisyZ
=9bvM
-----END PGP SIGNATURE-----

--Signature=_Wed__18_Dec_2013_09_52_03_+1100_u6ymJkaAjEug80Fh--
