From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [patch net-next v5 0/4] export device physical port id to
 userspace
Date: Fri, 26 Jul 2013 06:06:20 -0700
Message-ID: <1374843980.32309.9.camel@jtkirshe-mobl>
References: <1374840596-5748-1-git-send-email-jiri@resnulli.us>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lC6GUVw0qpAySTPqppu8"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@Dell.com,
	bhutchings@solarflare.com, john.r.fastabend@intel.com,
	or.gerlitz@gmail.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	vyasevic@redhat.com, amwang@redhat.com, johannes@sipsolutions.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:17173 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758772Ab3GZNHM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jul 2013 09:07:12 -0400
In-Reply-To: <1374840596-5748-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lC6GUVw0qpAySTPqppu8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-07-26 at 14:09 +0200, Jiri Pirko wrote:
> This patchset is based on patch by Narendra_K@Dell.com
> Once device which can change phys port id during its lifetime adopts this=
,
> NETDEV_CHANGEPHYSPORTID event will be added and driver will call
> call_netdevice_notifiers(NETDEV_NETDEV_CHANGEPHYSPORTID, dev) to propagat=
e
> the change to userspace.
>=20
> v1->v2: as suggested by Ben, handle -EOPNOTSUPP in rtnl code (wrapped up =
ndo call)
> v2->v3: adjusted patch 1 commit message
> v3->v4: used "%phN" for sysfs printf as suggested by DaveM
>         added igb/igbvf implementation as requested by Or Gerlitz
> v4->v5: used prandom_u32 to generate id in igb_probe
> 	removed duplicate code in ibgvf_probe
> 	pushed dev_err string into one line in igbvf_refresh_ppid
>=20
> Jiri Pirko (4):
>   net: add ndo to get id of physical port of the device
>   rtnl: export physical port id via RT netlink
>   net: export physical port id via sysfs
>   igb/igbvf: implement ndo_get_phys_port_id
>=20

Jiri-
I do not want to hold up the entire series, especially since three of
the four patches are not against our drivers, but I would like to have
these changes tested in our validation labs.

I will apply the series internally for testing.  In the meantime, if I
get an ACK from Carolyn Wyborny and Greg Rose on the igb/igbvf patch, I
am good with Dave applying the series.

>  drivers/net/ethernet/intel/igb/e1000_mbx.h |  1 +
>  drivers/net/ethernet/intel/igb/igb.h       |  2 ++
>  drivers/net/ethernet/intel/igb/igb_main.c  | 29 +++++++++++++++++++++-
>  drivers/net/ethernet/intel/igbvf/igbvf.h   |  3 +++
>  drivers/net/ethernet/intel/igbvf/mbx.h     |  1 +
>  drivers/net/ethernet/intel/igbvf/netdev.c  | 40 ++++++++++++++++++++++++=
++++++
>  drivers/net/ethernet/intel/igbvf/vf.c      | 34 ++++++++++++++++++++++++=
+
>  drivers/net/ethernet/intel/igbvf/vf.h      |  1 +
>  include/linux/netdevice.h                  | 20 +++++++++++++++
>  include/uapi/linux/if_link.h               |  1 +
>  net/core/dev.c                             | 18 ++++++++++++++
>  net/core/net-sysfs.c                       | 22 ++++++++++++++++
>  net/core/rtnetlink.c                       | 25 ++++++++++++++++++-
>  13 files changed, 195 insertions(+), 2 deletions(-)


--=-lC6GUVw0qpAySTPqppu8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIbBAABCgAGBQJR8nRMAAoJEOVv75VaS+3OqckP90QDQ41PNATq4ZBhQYdVROJc
3jdUqxo0wC3dhBwLZEFYlXhaKezrYWzqFuM1B37/SBj7V5d5UurIo5RUXP5Dzpb9
WPLxFpU2f8dVP9XPdIYLpYSoHvXPyaO6FdONOEbQY1fE6ZCstFRXyJWZAfF43r0v
DmD7GWQB1VOx4zSCiAvRcOhvVmpEsk9REgmoH05H+RmZrsUR6I9K5cInDzNkv+U/
ED5e3I5XDKmN8t55V272vfyKmVOPqi5tjETOOuZke9cdkX4CQyOnu7kyHRK5NSz9
W3H+/2bZGQiEbg5tKppgARbDsJknPUOrJdfrTHw2Vh/Cw0qX8ZJY3jhovials46n
CMQtbtITOseafLxwVSfyl9gNUOMoGyPt8J5LGYt4Q1AlI1K8prXjL5mHjpUI9sEz
vVswVHVsaBZYucht/MC35CzzCqh9hT1M7B0fWZVxhRI1jgXYPpw4BtuUdcriFA40
FMExubNeWBQ80TEqk/jQC6RfSMt6wlKgTD/hWgHU+bTs2cCkOl5U7LvS0lzdGRmP
YaPK/avlNnQqhPRWVpnXdikJJRXgZHII1twoGhIaM9LCPcIWv30bEJRPwpT5YtaW
adZ3Zz5eWM7pXGG+qdUo8h+9AhPzU9P9OpTIU3y/H0fooF4NQkUwA3V43fxwG9Cu
omLe0dkWBCFPBs5guiE=
=xOEe
-----END PGP SIGNATURE-----

--=-lC6GUVw0qpAySTPqppu8--
