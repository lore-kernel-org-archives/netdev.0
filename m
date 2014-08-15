From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: igbvf warning on 3.14.x
Date: Fri, 15 Aug 2014 06:27:05 -0700
Message-ID: <1408109225.2391.30.camel@jtkirshe-mobl>
References: <20140815131426.GA4638@gandi.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-m3BbqHVyQQIgcSm7xJ61"
Cc: netdev@vger.kernel.org,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: William Dauchy <william@gandi.net>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"mitch.a.williams" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42050 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884AbaHON1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 09:27:07 -0400
In-Reply-To: <20140815131426.GA4638@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-m3BbqHVyQQIgcSm7xJ61
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-08-15 at 15:14 +0200, William Dauchy wrote:
> Hello,
>=20
> I'm sometimes getting the following trace on a 3.14.x x86_64
> the boot cmdline has igb.max_vfs=3D2
>=20
> igbvf 0000:01:10.3: PF still resetting
> igbvf 0000:01:10.1: PF still resetting
> ------------[ cut here ]------------
> WARNING: CPU: 11 PID: 1 at
> drivers/net/ethernet/intel/igbvf/netdev.c:1718 igbvf_close+0x66/0x70()
> CPU: 11 PID: 1 Comm: swapper/0 Not tainted 3.14.17 #1
> Hardware name: Dell       C6100           /0D61XP, BIOS 1.69 06/22/2012
>  0000000000000009 ffffffffa95a5d15 0000000000000000 ffffffffa90954e8
>  ffff880c1d33e000 ffff880c1d33e7c0 8000000000000000 0000000000000001
>  0000000000000001 ffffffffa93a6676 ffff880c1d33e000 ffffc9000624bdb8
> Call Trace:
>  [<ffffffffa95a5d15>] ? dump_stack+0x49/0x7c
>  [<ffffffffa90954e8>] ? warn_slowpath_common+0x68/0x80
>  [<ffffffffa93a6676>] ? igbvf_close+0x66/0x70
>  [<ffffffffa946d878>] ? __dev_close_many+0x88/0xe0
>  [<ffffffffa946d9f5>] ? __dev_close+0x25/0x40
>  [<ffffffffa947440b>] ? __dev_change_flags+0xab/0x180
>  [<ffffffffa94744fe>] ? dev_change_flags+0x1e/0x60
>  [<ffffffffa9c401fb>] ? ic_close_devs+0x2c/0x40
>  [<ffffffffa9c41946>] ? ip_auto_config+0xbf3/0xec7
>  [<ffffffffa9273890>] ? kset_register+0x50/0x70
>  [<ffffffffa909a2fe>] ? __insert_resource+0x1e/0x130
>  [<ffffffffa9c40d53>] ? root_nfs_parse_addr+0xa7/0xa7
>  [<ffffffffa9c10ee5>] ? do_one_initcall+0x8c/0x107
>  [<ffffffffa9c110ba>] ? kernel_init_freeable+0x15a/0x1e1
>  [<ffffffffa9c10857>] ? do_early_param+0x9b/0x9b
>  [<ffffffffa959e9f0>] ? rest_init+0x80/0x80
>  [<ffffffffa959e9f5>] ? kernel_init+0x5/0xf0
>  [<ffffffffa95ac764>] ? ret_from_fork+0x74/0xa0
>  [<ffffffffa959e9f0>] ? rest_init+0x80/0x80
> ---[ end trace 90b2a2646f143695 ]---
> igbvf 0000:01:10.1: PF still resetting
> igbvf 0000:01:10.3: PF still resetting
> ixgbe 0000:03:00.0: removed PHC on eth6
> ixgbe 0000:03:00.1: removed PHC on eth7
>=20
>=20
> What can I do to help debug this trace? Or should I consider this a
> normal case?

Adding Carolyn (igb maintainer) and e1000-devel mailing list...

--=-m3BbqHVyQQIgcSm7xJ61
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJT7gqpAAoJEOVv75VaS+3OFgMQAJJjRIp9c8WxSVItzF0rGfcc
aqLJcssHiXOQDwiGpEfeNhTBNPl2cF3LJa4/OGaWdAuJO7ssws5Xx4uoBqiqzQRH
j33EIrhYL32uS8s20ybR4vlmnNrL/YuwKYLF8tufqRO0uT4LWVug6I4mmD4rkcWb
Dx4pKKgOlMz/l7FSnIQMHbZ+DqhGd88hbq33WIC6+2wEugH4eguFT9YyRs/UEbx5
pv+OLmClRKUftKZqICPECpJiKi5PAJ4FfvEqkJyO6JNl2xtDHsIGgNJ0ngHqI3PW
dMuNju4/z0I3hDYRL+YU6s8VjOrqnHw6If2d17dnhoSLiIFalTlDqNfE64utr/Cs
3+UXoqglebIZbPwRVwu9jEr9y1FEPds7ApS++2g70jUp1JaBdzYkOiAJWhy2PQZt
Zntc0QVv+3ct1o8Bm1ClXzlhae3ptXV7wvMn006q4d/837RPEfWCQkEV/+iFNLvJ
YDI6al+M1xcpnSckPNrR1k8hV7p+q8jUjwkOqSM7cqaafK1luFd7KhfZT4jEY8nJ
uOBhpkVmkwrs/HKplODT2EnSevLl4ZKohiLscJ/v+kQxx0l+4Pv/QttgdcblWoXW
iZakXHinmPUvFwssQWh7WFxKp5YdI9hxDcWsFiZBu9QXnLnNQ6VV7dFBK9+gnwGc
/NZ/35B3Q534naYeJg/K
=dmGN
-----END PGP SIGNATURE-----

--=-m3BbqHVyQQIgcSm7xJ61--
