From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] e1000e: Don't return uninitialized stats
Date: Fri, 19 May 2017 01:16:51 -0700
Message-ID: <1495181811.2376.0.camel@intel.com>
References: <20170425175433.ykc6ilm6uo7e6my2@f1.synalogic.ca>
         <20170517202413.18321-1-bpoirier@suse.com>
         <20170518.104614.1739169308591707817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-73tsMQzV5rvOLmN0wA1c"
Cc: s.priebe@profihost.ag, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, pmenzel@molgen.mpg.de,
        sasha.neftin@intel.com, aaron.f.brown@intel.com,
        stephen@networkplumber.org
To: David Miller <davem@davemloft.net>, bpoirier@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:38136 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750818AbdESIQz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 04:16:55 -0400
In-Reply-To: <20170518.104614.1739169308591707817.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-73tsMQzV5rvOLmN0wA1c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2017-05-18 at 10:46 -0400, David Miller wrote:
> From: Benjamin Poirier <bpoirier@suse.com>
> Date: Wed, 17 May 2017 16:24:13 -0400
>=20
> > Some statistics passed to ethtool are garbage because
> > e1000e_get_stats64()
> > doesn't write them, for example: tx_heartbeat_errors. This leaks kernel
> > memory to userspace and confuses users.
> >=20
> > Do like ixgbe and use dev_get_stats() which first zeroes out
> > rtnl_link_stats64.
> >=20
> > Fixes: 5944701df90d ("net: remove useless memset's in drivers
> > get_stats64")
> > Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> > Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
>=20
> Jeff, please be sure to pick this up, thanks.

Yep, I have it in my tree, thanks.
--=-73tsMQzV5rvOLmN0wA1c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZHqn0AAoJEOVv75VaS+3OeeQQAIOjVeb8KT8kWTEwWnI2tF+2
3XcpHaXQ0G6l9u/6UyWCuPSbsSNBuUtsY3yO2BtInOJ2tSfcm8W9xJnSsFlLkoJn
fkUA3Zm4dnMADAd3+OaZuxWMM73OtTqj8BWGNokcRni5uIvA2kOZ5YsXOVgNO/ZX
6uKVJizlIwKI8xsyY+NNPEP8ujpkC3ysjGMmqtMw/aqz/0qd8rPmkEMn4Cj9cu6g
NXG6D2u3beycdSdIlRDzmjD3q5b3XigSht3hsoNTsdPwf/EIrEAqXJBfEobZh7ut
u+QUz5YUgR8WYODSPtLb9tkBPMsaiz/noEPjH/D0qVXs/f4aguzTsIqTGteX5bj4
+aNOFsC1JzzO+tfxMQR736gU3/2Ci6r20oZkwrazpBQHMbNHwBbisjPa38PsWDxI
L4VcqxQzCuCrEqNGrzF/D3JwuE7iP/tIK1bozwJAGFcj3Ppm1CgI1DSQnYZBSUHR
7nxfDJAqGrCPFt+URRI9AqQmYTvbeXpE9FNyRJy/vdOtTD8iX88DrIsUitsak/No
IZbQf90bnQKLnxdpuR9nOyXDtZtGDI8C0UtCe6emsZdS9Xq+SKqvxV3cLBLuZX9F
04bUexSqrawM+nSk1wofDR+drju+7ccH/1WbB9c9OwrU0NfSeGpP3CPW7gmiEuaL
FsFSwVSGeW0ojDEJ7m1m
=ncLl
-----END PGP SIGNATURE-----

--=-73tsMQzV5rvOLmN0wA1c--
