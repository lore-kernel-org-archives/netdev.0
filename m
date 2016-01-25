From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCHv2 3/4] ARM: tegra: use build-in device properties with
 rfkill_gpio
Date: Mon, 25 Jan 2016 13:18:40 +0100
Message-ID: <20160125121840.GA20452@ulmo.nvidia.com>
References: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com>
 <1453712629-143317-4-git-send-email-heikki.krogerus@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Dxnq1zWXvFF0Q93v"
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
	Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>
To: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1453712629-143317-4-git-send-email-heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 25, 2016 at 12:03:48PM +0300, Heikki Krogerus wrote:
> Pass the rfkill name and type to the device with properties
> instead of driver specific platform data.
>=20
> Signed-off-by: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> CC: Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> CC: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> CC: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
> ---
>  arch/arm/mach-tegra/board-paz00.c | 17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)

Looks fine to me. We might want to wait for Marc (Cc'ed) to give this a
spin, since I don't have the hardware. For reference, the series can be
found here:

	http://patchwork.ozlabs.org/patch/572640/
	http://patchwork.ozlabs.org/patch/572644/
	http://patchwork.ozlabs.org/patch/572643/
	http://patchwork.ozlabs.org/patch/572642/

Johannes, I assume that you'll want to take this through your tree
because of the dependency? In that case:

Acked-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

--Dxnq1zWXvFF0Q93v
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJWphKcAAoJEN0jrNd/PrOhVlMP/i5QMgu5bU6jLEAYoubopBXw
VgZPSBqaddHK6qgVntB/9kwD6o8h11xb3FSE4yOSy7bLHHkUjYNpbVPY395nhkCW
mwevqUgh7RjD5sRXPdbT0wbqzRQ6+/1glS+yqV2CL49o8wPasYOsmJifZw0hyG0j
/5N0b4Tgq4PgZbjh02kVNcwPMc6mV2lrNCRkOi8TBsXoHHNUA3D1m7/qW2Hr0vEi
PFJzPddKsEIpoUnohzhxrbwsZUXCg+Cdan25FWU8a/P7hmM/PvyY/lalsJ+2pZAc
V3NeMgAUldNbubzsFoSL041OHIo165aqQZozYDBbhLaUbsIeAw66C3LwO3+6GLLG
86gsMlk8vDD91Lh3ZG29Z6wS7cxnDCxGTTl3ltjbivS7ohdd+XP8ChCBExVdb+YQ
Jw4QvIr6rPWXLzEhkSGEj6MinCcSPD7RrIJp0Z204LBIbuy+nXdhzSNH2V3WuU0C
zJuHyElAuCNN5UadBPaVopFIRMwxtDRpmDUiVFcBvPIQx5BCxYD1pP1M1XR9SQIE
X5lHJ5WI6Z5hG/Z183wK8wuGx9itVbviSg9V+Po2eFk3dWzEJ8AHbx4mJtKgLhks
1MhnQrWH3mCIjDF9W0Y5PNcuYd6HBesV/gY84BdGO5xy6cdT57LfI6ZTubIYZIhM
TbiCVZw9K1FvOObSqanK
=8JOH
-----END PGP SIGNATURE-----

--Dxnq1zWXvFF0Q93v--
