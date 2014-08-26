From: William Dauchy <william@gandi.net>
Subject: Re: igbvf warning on 3.14.x
Date: Tue, 26 Aug 2014 17:54:24 +0200
Message-ID: <20140826155424.GM8801@gandi.net>
References: <20140815131426.GA4638@gandi.net>
 <1408109225.2391.30.camel@jtkirshe-mobl>
 <20140826073613.GH8801@gandi.net>
 <9BBC4E0CF881AA4299206E2E1412B6264FBD7D4B@ORSMSX102.amr.corp.intel.com>
 <9B4A1B1917080E46B64F07F2989DADD6533D2F95@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vdqwC0msT4ilQ2it"
Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	William Dauchy <william@gandi.net>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:42801 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751482AbaHZPyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 11:54:07 -0400
Content-Disposition: inline
In-Reply-To: <9B4A1B1917080E46B64F07F2989DADD6533D2F95@ORSMSX114.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vdqwC0msT4ilQ2it
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug26 15:25, Fujinaka, Todd wrote:
> Can you please send clear repro steps and I'll submit it to our lab for r=
epro. We'll need what equipment you're running (on both sides of the link),=
 the kind of traffic you're running, the OS & kernel you're running, etc.

the switch used is a cisco C6506
the server is a dell C6100
the network card intel 82576 Gigabit Network Connection

I'm using a linux stable release v3.14.x (last version)
the boot cmdline has igb.max_vfs=3D2 as argument
no specific traffic but the machine is booting through pxe boot using
nfs

the trace is a bit random at boot time (some boot are clean)
here is a the trace as a reminder:

igbvf 0000:01:10.3: PF still resetting
igbvf 0000:01:10.1: PF still resetting
------------[ cut here ]------------
WARNING: CPU: 11 PID: 1 at
drivers/net/ethernet/intel/igbvf/netdev.c:1718 igbvf_close+0x66/0x70()
CPU: 11 PID: 1 Comm: swapper/0 Not tainted 3.14.17 #1
Hardware name: Dell       C6100           /0D61XP, BIOS 1.69 06/22/2012
 0000000000000009 ffffffffa95a5d15 0000000000000000 ffffffffa90954e8
 ffff880c1d33e000 ffff880c1d33e7c0 8000000000000000 0000000000000001
 0000000000000001 ffffffffa93a6676 ffff880c1d33e000 ffffc9000624bdb8
Call Trace:
 [<ffffffffa95a5d15>] ? dump_stack+0x49/0x7c
 [<ffffffffa90954e8>] ? warn_slowpath_common+0x68/0x80
 [<ffffffffa93a6676>] ? igbvf_close+0x66/0x70
 [<ffffffffa946d878>] ? __dev_close_many+0x88/0xe0
 [<ffffffffa946d9f5>] ? __dev_close+0x25/0x40
 [<ffffffffa947440b>] ? __dev_change_flags+0xab/0x180
 [<ffffffffa94744fe>] ? dev_change_flags+0x1e/0x60
 [<ffffffffa9c401fb>] ? ic_close_devs+0x2c/0x40
 [<ffffffffa9c41946>] ? ip_auto_config+0xbf3/0xec7
 [<ffffffffa9273890>] ? kset_register+0x50/0x70
 [<ffffffffa909a2fe>] ? __insert_resource+0x1e/0x130
 [<ffffffffa9c40d53>] ? root_nfs_parse_addr+0xa7/0xa7
 [<ffffffffa9c10ee5>] ? do_one_initcall+0x8c/0x107
 [<ffffffffa9c110ba>] ? kernel_init_freeable+0x15a/0x1e1
 [<ffffffffa9c10857>] ? do_early_param+0x9b/0x9b
 [<ffffffffa959e9f0>] ? rest_init+0x80/0x80
 [<ffffffffa959e9f5>] ? kernel_init+0x5/0xf0
 [<ffffffffa95ac764>] ? ret_from_fork+0x74/0xa0
 [<ffffffffa959e9f0>] ? rest_init+0x80/0x80
---[ end trace 90b2a2646f143695 ]---
igbvf 0000:01:10.1: PF still resetting
igbvf 0000:01:10.3: PF still resetting
ixgbe 0000:03:00.0: removed PHC on eth6
ixgbe 0000:03:00.1: removed PHC on eth7

Regards,
--=20
William

--vdqwC0msT4ilQ2it
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlP8rbAACgkQ1I6eqOUidQEIpwCgjwdWCzZy43gE/KshGqKA1tAy
fK8AnRi0dXP9UCjp73pPIYxP+1pv9w/n
=9nVY
-----END PGP SIGNATURE-----

--vdqwC0msT4ilQ2it--
