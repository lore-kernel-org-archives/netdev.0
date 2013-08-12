From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the cgroup tree with the net-next tree
Date: Mon, 12 Aug 2013 12:21:49 +1000
Message-ID: <20130812122149.c5f7d4497a135b9500b61b27@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__12_Aug_2013_12_21_49_+1000_=7FoCNWZDdfSbhxe"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__12_Aug_2013_12_21_49_+1000_=7FoCNWZDdfSbhxe
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Tejun,

Today's linux-next merge of the cgroup tree got a conflict in
include/net/netprio_cgroup.h between commit 378307217ed9 ("cls_cgroup.h
netprio_cgroup.h: Remove extern from function prototypes") from the
net-next tree and commit 6d37b97428d2 ("netprio_cgroup: pass around @css
instead of @cgroup and kill struct cgroup_netprio_state") from the cgroup
tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/net/netprio_cgroup.h
index 379dd5d,a24f8bb..0000000
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@@ -25,11 -25,7 +25,7 @@@ struct netprio_map=20
  	u32 priomap[];
  };
 =20
- struct cgroup_netprio_state {
- 	struct cgroup_subsys_state css;
- };
-=20
 -extern void sock_update_netprioidx(struct sock *sk);
 +void sock_update_netprioidx(struct sock *sk);
 =20
  #if IS_BUILTIN(CONFIG_NETPRIO_CGROUP)
 =20

--Signature=_Mon__12_Aug_2013_12_21_49_+1000_=7FoCNWZDdfSbhxe
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSCEbBAAoJEECxmPOUX5FEmFwP/1mDWdFH/I1e572GkdJiBzj4
lYp11XPDdJwT8FMNRn6qSO3M0/Rk4NZ8TVTD+1Tmw4qZfn73rMcm27meyU1QbaZo
dY7p2C2ckAdl8i0n88Qi06acUiqSRDc4kqUx31tOWNLhB0bvxuw07yROICSTrXvt
TsUxsNZDjCsTtj982sLdbbfFoKbPlqfic8fJuL1Js/jdJuC10AgMhx5QlvwJ0oL/
J35IcF4xA7OmHMTof1kmsnJyP9UnS0iuTA7+XUaSycBn6FP+0ZOsLJJFhMIkR4E0
43cQlfCtPighkS0UJiMfinNuRUisqFdAuw+Pfr+702BgQgOU9b6KlYBUCc+YoPTR
VFPIKqenuQt/PFGnQRx/xr3r5e8nmgjZfW1n6hvt40SmgiZi4of4/Iurky7l1j5a
m2rm/AtjeogwXjloGED7MZscocyVw2y0QChj0WnqwFShVjpIRGhINaST10moWPUb
YO2U2s8+LlnP2qpwL6+j/uAsC4gHZLLqSTkZ6Wj0P2pUt2QjxAapK5tI11IvdP3y
cjs0XwVmI2p2XtfFbgCseAy5rdCXSYV92tKfFgbcwTJq+m3h1eKQhcmRq693zBQ2
ARdm5uV6/QSVjEJlG5uAbdhSU+E9R1z0q78NIzOZjSXBqJXfKdH2IX4/dACmVygg
qIf/J3p4qp49+0k87T/Z
=JTKZ
-----END PGP SIGNATURE-----

--Signature=_Mon__12_Aug_2013_12_21_49_+1000_=7FoCNWZDdfSbhxe--
