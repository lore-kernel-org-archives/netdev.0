From: Tony Breeds <tony@bakeyournoodle.com>
Subject: Re: [PATCH] Replace IS_ENABLED(CONFIG_FCOE) in linux/netdevice.h
Date: Fri, 16 Mar 2012 14:22:40 +1100
Message-ID: <20120316032239.GA31524@thor.bakeyournoodle.com>
References: <1331857815-2333-1-git-send-email-tony@bakeyournoodle.com>
 <1331859345.2424.38.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="7AUc2qLy4jB3hD7Z"
Cc: Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>, devel@open-fcoe.org,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1331859345.2424.38.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 16, 2012 at 12:55:45AM +0000, Ben Hutchings wrote:
> On Fri, 2012-03-16 at 11:30 +1100, Tony Breeds wrote:
> > On platforms that (or configs that do not have PCI support building any
> > code that includes linux/netdevice.h we see the following warnings:
> >=20
> > include/linux/netdevice.h:964:1: warning: "__enabled_CONFIG_FCOE" is no=
t defined [-Wundef]
> > include/linux/netdevice.h:964:1: warning: "__enabled_CONFIG_FCOE_MODULE=
" is not defined [-Wundef]
> >=20
> > In the case of this file we can trivially fallback to the old school
> >  #if defined(...) syntax.
> [...]
>=20
> The script that generates those symbols should be fixed instead.

Sorry all, Yes this patch is bogus.

The platform was seeing this error wasn't sourceing
drivers/scsi/Kconfig, so those symbols will never be defined.  I imagine
that's pretty rare.

Yours Tony

--7AUc2qLy4jB3hD7Z
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPYrH/AAoJEEsCiJRY75GKw6wP/1UC5CCUr5FUaQbQhjgEchzs
LcjjC8XSh9ATNUAST4daj8S7EtNlOSrK1NS2v+NSyr2wmSfGOPNZqJQc+Ak5CoWF
sSm7qqiVoZpJsV/scyhBJBoAxEnoexmjhfQuqCaLKELtrLGljS5ktdd1Xkr2msy6
z1cpeOMfJBzqI3NYYjtR0vilHbJjvYnSp9z/dLgBOHbrMsLtueeiEEz4tN3SF/sG
NmjdEX7l2I1ia4uclEdkpa5W5KEZ0jwub7hzExoU/my097w/fq0hO7+IUhZ7Iw7t
g9tri88gR5FY+NPxJV+zdvrDbAzNnLekrTil7fo8M95GrcuU3DyDVYBjFX501LPg
ruPJdtdEKfIuCCVjk2V6uVSqfPnRskpTRowNhqVoRmPsemUgoF9Cl/8eY6yCPf/2
nCs6iyddhDGgrtP2UQoPHq3g9ajsNxIqj05zLrkI2aZPDMM9Z/vmbLkR9SOf0d+1
Lom/yTcl3FCDTk86sJGNCjN+kY3ouTa8LnK9O+muuyuPDJsoBqw1TCAm3bAMcyBO
STijkdOMZ8zZMW5OgSklqP7l16S0a4e7w3bgClH3dLlV2FBkP+JLxrtXZYiI2Ojk
PF6zLr21gBMw3oFcJ2LwDvoBKBqccpk5v6+tS/mMzxNXjFXTuSxWi5Zu8K/5xzPa
uaryfkrldjpG7j5+Ukgc
=uDK7
-----END PGP SIGNATURE-----

--7AUc2qLy4jB3hD7Z--
