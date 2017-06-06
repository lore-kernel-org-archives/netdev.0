From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 1/1] e1000e: Undo e1000e_pm_freeze if
 __e1000_shutdown fails
Date: Tue, 06 Jun 2017 13:46:26 -0700
Message-ID: <1496781986.86439.3.camel@intel.com>
References: <20170531.110833.1362264472730468352.davem@davemloft.net>
         <20170531155043.3596-1-jani.nikula@intel.com>
         <20170531155043.3596-2-jani.nikula@intel.com>
         <20170602.141426.713378366601051907.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-P0nDB+VdAD0T/cKD8nLp"
Cc: daniel.vetter@ffwll.ch, airlied@gmail.com,
        intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
        jani.nikula@linux.intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        chris@chris-wilson.co.uk, tvrtko.ursulin@intel.com,
        davidx.m.ertman@intel.com, bruce.w.allan@intel.com
To: David Miller <davem@davemloft.net>, jani.nikula@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170602.141426.713378366601051907.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-P0nDB+VdAD0T/cKD8nLp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2017-06-02 at 14:14 -0400, David Miller wrote:
> From: Jani Nikula <jani.nikula@intel.com>
> Date: Wed, 31 May 2017 18:50:43 +0300
>=20
> > From: Chris Wilson <chris@chris-wilson.co.uk>
> >=20
> > An error during suspend (e100e_pm_suspend),
>=20
>  ...
> > lead to complete failure:
>=20
>  ...
> > The unwind failures stems from commit 2800209994f8 ("e1000e:
> > Refactor PM
> > flows"), but it may be a later patch that introduced the non-
> > recoverable
> > behaviour.
> >=20
> > Fixes: 2800209994f8 ("e1000e: Refactor PM flows")
> > Bugzilla: https://bugs.freedesktop.org/show_bug.cgi?id=3D99847
> > Cc: Tvrtko Ursulin <tvrtko.ursulin@intel.com>
> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Cc: Dave Ertman <davidx.m.ertman@intel.com>
> > Cc: Bruce Allan <bruce.w.allan@intel.com>
> > Cc: intel-wired-lan@lists.osuosl.org
> > Cc: netdev@vger.kernel.org
> > Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> > [Jani: bikeshed repainted]
> > Signed-off-by: Jani Nikula <jani.nikula@intel.com>
>=20
> Jeff, please make sure this gets submitted to me soon.

Expect it later tonight, just finishing up testing.
--=-P0nDB+VdAD0T/cKD8nLp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlk3FKIACgkQ5W/vlVpL
7c7OCw//ZSpQsILqkMfAF0x0nuDBeCdDpTA0wTbgUhrnKgKile33cIwgUrSkz20U
zbB9kUJB0HcIMKKVbQ0VgKH/cHTdqnXA2XeEiK8I6ec3plc+srG+NVW8AvN14fwX
DsY63SzTyIkZNzRtskd8E5ZyGAxpQvBlTlc5QQ+FFOZ4q971GYWD8CiuXX6vmyfI
Bk3YyGQIU0R0MLf52E0FRpDMCSC/if9DeuW8bWIwXPdrK3crSyIpSHorfmVlwL0q
a7EIYe1d5xQjzeHkoqzpM3M/N1B3+VKoV7QfGYDbEsmF+BtjOGJRizeSNd90njm6
oYJ6BMBtDA4TqLP6ItU1vHF91Y69+G9tvrOxLLz3Rvud5w+BavOQFzpDqDRVVvIj
DOcyOQDxPxv5baGkPs6dnEHdbu3+8+Hg4W6vwlq0ZQ/+tsLhmaFApZZtxcHkE+ok
f9PSQUjv0EtprWi39hRph18Zoc/KR9/NHSoukQmqOgdmaBnFza1QnUKArQngEFbw
AymbpXTb07vADuixI2AglS1gBTudU7LmiGoiDc/Qkkgu+S8lVMSOVcc7bYDPK/XK
wy+lo2u13DsLpSzWM3NbFAba2h39U79DWkinH6SfSNJv/Bl3TLDZ+rGQ1BJ878IB
nJ583HdqSTaa71HEZqE9FmnweCgTZLPnx9QS/iAU9iaAvsQKokE=
=K+he
-----END PGP SIGNATURE-----

--=-P0nDB+VdAD0T/cKD8nLp--
