From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute2 v3.0.1
Date: Wed, 23 Nov 2011 12:29:51 -0800
Message-ID: <20111123122951.6ad25f74@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
 boundary="Sig_/m3ujiHXs+hL2j_EucPxg_GD"; protocol="application/pgp-signature"
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/m3ujiHXs+hL2j_EucPxg_GD
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

This version of iproute2 utilities intended for use with 3.1.0 or
later kernel, but should be backward compatible with older releases.
It includes many bug fixes for error cases, support for new kernel features,
and manual enhancements.

Source: no longer at linux-foundation
  http://kernel.org/pub/linux/kernel/utils/networking/iproute2/iproute2-3.1=
.0.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

This version is signed with my GPG public key

Report problems (or enhancements) to the netdev@vger.kernel.org mailing lis=
t.

Changelog since last version v2.6.39

Andreas Henriksson (2):
      iproute2: Fix building xt module against xtables version 6
      iproute2: Remove "monitor" from "ip route help" output

Bin Li (1):
      ip: fix typo in ip link manual page

Christoph Biedl (1):
      ip: fix display of prefix cache info

Dan McGee (6):
      iproute2: Remove ChangeLog
      Make iproute2 configure script more flexible
      iptuntap: avoid double open
      genl: remove unused code
      ensure uptime is initialized if /proc/uptime cannot be opened
      xt: only unset fields if m is non NULL

David Ward (1):
      xfrm: Update documentation

Eric W. Biederman (3):
      iproute2: Add processless network namespace support
      iproute2: Auto-detect the presence of setns in libc
      iproute2: Fail "ip netns add" on existing network namespaces.

Florian Westphal (3):
      tc: man: add man page for choke scheduler
      tc: man: update sfq man page
      tc: filter: fix default 'protocol all' on little-endian platforms

Gilles Espinasse (1):
      iproute2: fix minor typo in comments

Jiri Benc (1):
      iproute2: fix changing of ip6ip6 tunnel parameters

Michal Soltys (2):
      HFSC (7) & (8) documentation + assorted changes
      HFS manpage changes

Mike Frysinger (1):
      tc: fix parallel build file with lex/yacc

Petr Sabata (4):
      iproute2: Remove unreachable code
      iproute2: ss - fix missing parameters
      iproute2: lnstat - fix typos
      iproute2: arpd - fix usage and manpage options

Petr =C5=A0abata (1):
      Display closed UDP sockets on 'ss -ul'

Sridhar Samudrala (1):
      iproute2: Fix usage and man page for 'ip link'

Stephen Hemminger (14):
      Update .gitignore
      Update kernel headers to 3.0
      Fix test for EOF on continuation line
      Remove redundant limits.h
      Add QFQ scheduler
      Add LLDP to ethernet type table
      Update headers to 3.0.4
      Add ntable to ip man page
      ip: fix man page warnings
      v3.0.0
      Update to 3.1-rc9 kernel headers
      ip: fix exit codes
      cleanup ematch yacc files
      v3.1.0

Thomas Jarosch (12):
      Fix pipe I/O stream descriptor leak in init_service_resolver()
      Fix file descriptor leak on error in rtnl_hash_initialize()
      Fix wrong comparison in cmp_print_eopt()
      Fix wrong sanity check in choke_parse_opt()
      Fix memory leak of lname variable in get_target_name()
      Add missing closedir() call in do_show()
      Fix file descriptor leak on error in iproute_flush_cache()
      Fix file descriptor leak on error in read_viftable()
      Fix file descriptor leak on error in read_mroute_list()
      Fix file descriptor leak in do_tunnels_list()
      Fix file descriptor leak on error in read_igmp()
      Fix unterminated readlink() buffer usage


--Sig_/m3ujiHXs+hL2j_EucPxg_GD
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOzVe/AAoJEICnf2CVzeR+V/MQAMjcK6cY68UoPEwi36h0fj8X
6vdj20f5xm5aFZfyPfUkZBjwX41eB5L+aiUARd61DG2Wle3R/skOl0V2byU1tC3d
PukF8cM8AUyfajVSorP0rcxV3kDs7/pGksAqmI6D9IiQGF32adRWjLh3sQm1Ppn/
QagTcBImhLTePkFrk7PlxptM0DH9hnm/uN0lRoZ7K4O6WwXTrJKaK9ymvdEIaJND
+5zXExWNWeIBX2w8auEvi8S/Q8Rd3vxraFlAU5rrqRJ/QNJYlzBxk1XBRpF3Rnk4
QLpNAbgifGJ9xAVYgnhT34bYJPtUAtVGlt3VDTuY03GJB+BSgaJJpOWND8lisKaZ
AF9/GIVSzAEoLWqnmeaFJlrSUgvhfiGEkpY082//avdSU9+Gx6FVG8ps7NboeiNf
KxU2G6oZVHrXzG4u/3mVGssG7+ZZTAD9JDqFG2xuv69avHI4/iYa+plM+DZeK0eq
cty9aUPUCbLbPSbUVq5TImkdQCR8O9+fEfn/3Hh+3n/Td4PfRzWoglmx9vvn8mY9
G8QlDPdI0HJ+oKpPiKX7QpAQ1HSt15ZjbIgu/5vbHtdrC1zeBUiYF+Dc4/I1/xms
+4cWs3ZcLwyruI5fnzkTCnsGqjHu4PxtBvuMNIrm1DFYCFqmbt9JuQPM0Zc10qkI
8JXeddHEqBeL3S8bM4Cm
=XPHQ
-----END PGP SIGNATURE-----

--Sig_/m3ujiHXs+hL2j_EucPxg_GD--
