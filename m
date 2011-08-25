From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next v2 00/10] Fix net header dependencies
Date: Thu, 25 Aug 2011 05:38:44 +0100
Message-ID: <1314247131.27179.116.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Vmr2LoyvZEe9ta86SeKQ"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49067 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751229Ab1HYEiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 00:38:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Vmr2LoyvZEe9ta86SeKQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Various networking headers depend on definitions from others which they
don't include.  We can't fix all of these, because some definitions are
duplicated between kernel headers and glibc headers and we cannot tell
which is the right one to include.  We also have to be wary of
introducing a dependency cycle.

Since v1, I've dropped the patches to <linux/scc.h> and <linux/if_ppp.h>
and added the acknowledgements I got last time.

Ben.

Ben Hutchings (10):
  headers, pppox: Add missing #include to <linux/if_pppox.h>
  headers, ax25: Add missing #include to <linux/netrom.h>,
    <linux/rose.h>
  headers, pppol2tp: Use __kernel_pid_t in <linux/pppol2tp.h>
  headers, net: Use __kernel_sa_family_t in more definitions shared
    with userland
  headers, net: Define struct __kernel_sockaddr, replacing struct
    sockaddr
  headers, netfilter: Use kernel type names __u8, __u16, __u32
  headers, tipc: Add missing #include to <linux/tipc_config.h> for
    userland
  headers, netfilter: Add missing #include <limits.h> for userland
  headers, xtables: Add missing #include <linux/netfilter.h>
  headers, can: Add missing #include to <linux/can/bcm.h>

 include/linux/atalk.h                     |    3 ++-
 include/linux/ax25.h                      |    2 +-
 include/linux/caif/caif_socket.h          |    7 +------
 include/linux/can.h                       |    2 +-
 include/linux/can/bcm.h                   |    1 +
 include/linux/if.h                        |   12 ++++++------
 include/linux/if_pppol2tp.h               |    2 +-
 include/linux/if_pppox.h                  |    9 +++++----
 include/linux/in.h                        |    2 +-
 include/linux/ipx.h                       |    2 +-
 include/linux/irda.h                      |    9 +++------
 include/linux/l2tp.h                      |    7 ++++---
 include/linux/llc.h                       |   10 +++++++---
 include/linux/netfilter/xt_connlimit.h    |    1 +
 include/linux/netfilter/xt_conntrack.h    |    1 +
 include/linux/netfilter/xt_iprange.h      |    1 +
 include/linux/netfilter_arp/arp_tables.h  |   14 +++++++-------
 include/linux/netfilter_decnet.h          |    3 +++
 include/linux/netfilter_ipv4.h            |    3 +++
 include/linux/netfilter_ipv4/ip_tables.h  |   20 ++++++++++----------
 include/linux/netfilter_ipv6.h            |    3 +++
 include/linux/netfilter_ipv6/ip6_tables.h |   22 +++++++++++-----------
 include/linux/netlink.h                   |    2 +-
 include/linux/netrom.h                    |    2 ++
 include/linux/phonet.h                    |    6 ++++--
 include/linux/rose.h                      |    7 +++++--
 include/linux/socket.h                    |   17 +++++++++--------
 include/linux/tipc_config.h               |    4 ++++
 include/linux/un.h                        |    4 +++-
 include/linux/x25.h                       |    3 ++-
 30 files changed, 104 insertions(+), 77 deletions(-)

--=20
1.7.5.4



--=-Vmr2LoyvZEe9ta86SeKQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATlXR1Oe/yOyVhhEJAQp8gg/+IgokQGKBs5nlnSK9RaUm8ngPvFEdlEZr
NmNmtShyxHra1Iq1pmzyUXviy2dcPNEUPV/uU3IRCdfdHhaDx48pm7UNkbLE5foE
3HOLkru3w6X8Xnx6PLTU022yK6cNEKTHYlzGw2mUFU+RPiPCtiZdjtGhIR3MAY8r
uMeHLbiJC5MF4NthdxPV/fdltL2YSn9tbeP1zlWjwShnDJEk7lDHzUvliORfwPcM
aEcoAvb4DD7PzwqLPCzs52RdfkKkNHI27/toq7jZSF6ZUCIlb5TO3dCwwFvnLJ+I
1GwJdMjPlqqCP4cARGAZXZz5w9pStFJJ4wS2Dnp6/IcyXGTlPMypvx9DGU0y0hRL
ph4Ch9DIvqAzL3+OgLnU+u/sxBWHnNSWlJ1HYeFOqdnDeC6gyGs3/MFyKFUbY2N7
8Z/HekMjVaTI4hgmiODZYQq3eCjOH9josopyReq/05V0jRKeTulj+7L0NJKBlerF
UVK/MtQvPO7ic7eRqlaa9kfHAOn/f7WFr8UNEayp5cDLZdW9SOsN4PnAVa5ZbUZM
PJoKw2isegoD3aMuoICzipluMllsY6lBzyZI+t82db31yLWuu9MwUkfSawdccY8b
pS728kl5wuhv/CBgINECjNZ+0lNLgcq/b9XPjg9+zYcnzfjNDnJWGKpRdMosv4DP
i3daMI1kCqQ=
=Sucm
-----END PGP SIGNATURE-----

--=-Vmr2LoyvZEe9ta86SeKQ--
