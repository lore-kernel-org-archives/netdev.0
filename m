From: William Dauchy <william@gandi.net>
Subject: igbvf warning on 3.14.x
Date: Fri, 15 Aug 2014 15:14:26 +0200
Message-ID: <20140815131426.GA4638@gandi.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="a8Wt8u1KmwUX3Y2C"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:36372 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138AbaHONWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 09:22:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

I'm sometimes getting the following trace on a 3.14.x x86_64
the boot cmdline has igb.max_vfs=3D2

igbvf 0000:01:10.3: PF still resetting
igbvf 0000:01:10.1: PF still resetting
------------[ cut here ]------------
WARNING: CPU: 11 PID: 1 at
drivers/net/ethernet/intel/igbvf/netdev.c:1718 igbvf_close+0x66/0x70()
CPU: 11 PID: 1 Comm: swapper/0 Not tainted 3.14.17 #1
Hardware name: Dell =A0 =A0 =A0 C6100 =A0 =A0 =A0 =A0 =A0 /0D61XP, BIOS 1.6=
9 06/22/2012
=A00000000000000009 ffffffffa95a5d15 0000000000000000 ffffffffa90954e8
=A0ffff880c1d33e000 ffff880c1d33e7c0 8000000000000000 0000000000000001
=A00000000000000001 ffffffffa93a6676 ffff880c1d33e000 ffffc9000624bdb8
Call Trace:
=A0[<ffffffffa95a5d15>] ? dump_stack+0x49/0x7c
=A0[<ffffffffa90954e8>] ? warn_slowpath_common+0x68/0x80
=A0[<ffffffffa93a6676>] ? igbvf_close+0x66/0x70
=A0[<ffffffffa946d878>] ? __dev_close_many+0x88/0xe0
=A0[<ffffffffa946d9f5>] ? __dev_close+0x25/0x40
=A0[<ffffffffa947440b>] ? __dev_change_flags+0xab/0x180
=A0[<ffffffffa94744fe>] ? dev_change_flags+0x1e/0x60
=A0[<ffffffffa9c401fb>] ? ic_close_devs+0x2c/0x40
=A0[<ffffffffa9c41946>] ? ip_auto_config+0xbf3/0xec7
=A0[<ffffffffa9273890>] ? kset_register+0x50/0x70
=A0[<ffffffffa909a2fe>] ? __insert_resource+0x1e/0x130
=A0[<ffffffffa9c40d53>] ? root_nfs_parse_addr+0xa7/0xa7
=A0[<ffffffffa9c10ee5>] ? do_one_initcall+0x8c/0x107
=A0[<ffffffffa9c110ba>] ? kernel_init_freeable+0x15a/0x1e1
=A0[<ffffffffa9c10857>] ? do_early_param+0x9b/0x9b
=A0[<ffffffffa959e9f0>] ? rest_init+0x80/0x80
=A0[<ffffffffa959e9f5>] ? kernel_init+0x5/0xf0
=A0[<ffffffffa95ac764>] ? ret_from_fork+0x74/0xa0
=A0[<ffffffffa959e9f0>] ? rest_init+0x80/0x80
---[ end trace 90b2a2646f143695 ]---
igbvf 0000:01:10.1: PF still resetting
igbvf 0000:01:10.3: PF still resetting
ixgbe 0000:03:00.0: removed PHC on eth6
ixgbe 0000:03:00.1: removed PHC on eth7


What can I do to help debug this trace? Or should I consider this a
normal case?

Regards,
--=20
William

--a8Wt8u1KmwUX3Y2C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlPuB7IACgkQ1I6eqOUidQEXHACfWRgxp+5wv6QYdOaNM8mymvyn
hUIAoLK5p8GhFO6KiCzxGoqhjCq5gYYa
=EMd+
-----END PGP SIGNATURE-----

--a8Wt8u1KmwUX3Y2C--
