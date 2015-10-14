From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 5/6] e1000 driver remove checkpatch errors, warnings and
 checks.
Date: Tue, 13 Oct 2015 22:37:41 -0700
Message-ID: <1444801061.2870.58.camel@intel.com>
References: <1444772362-25090-1-git-send-email-januszwolak@awokados.com.pl>
	 <1444772362-25090-5-git-send-email-januszwolak@awokados.com.pl>
	 <561D846E.1050405@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gm/tu2Zsz2kKGoFhgIq1"
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Janusz Wolak <januszvdm@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Janusz Wolak <januszwolak@awokados.com.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19621 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815AbbJNFhn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 01:37:43 -0400
In-Reply-To: <561D846E.1050405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gm/tu2Zsz2kKGoFhgIq1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-10-13 at 15:23 -0700, Alexander Duyck wrote:
> On 10/13/2015 02:39 PM, Janusz Wolak wrote:
> > From: Janusz Wolak <januszvdm@gmail.com>
> >
> > Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
> > ---
> >   drivers/net/ethernet/intel/e1000/e1000_param.c | 114
> ++++++++++++++++++-------
> >   1 file changed, 82 insertions(+), 32 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/intel/e1000/e1000_param.c
> b/drivers/net/ethernet/intel/e1000/e1000_param.c
> > index c9cde35..9ec730e 100644
> > --- a/drivers/net/ethernet/intel/e1000/e1000_param.c
> > +++ b/drivers/net/ethernet/intel/e1000/e1000_param.c
> > @@ -1,5 +1,5 @@
> > =20
> /********************************************************************
> ***********
> > -
> > +*
> >     Intel PRO/1000 Linux driver
> >     Copyright(c) 1999 - 2006 Intel Corporation.
> >  =20
> > @@ -45,10 +45,10 @@
> >  =20
> >   #define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] =3D OPTION_UNSET }
> >   #define E1000_PARAM(X, desc) \
> > -     static int X[E1000_MAX_NIC+1] =3D E1000_PARAM_INIT; \
> > +     static int X[E1000_MAX_NIC + 1] =3D E1000_PARAM_INIT; \
> >       static unsigned int num_##X; \
> >       module_param_array_named(X, X, int, &num_##X, 0); \
> > -     MODULE_PARM_DESC(X, desc);
> > +     MODULE_PARM_DESC(X, desc)
> >  =20
> >   /* Transmit Descriptor Count
> >    *
> > @@ -200,6 +200,7 @@ struct e1000_option {
> >               } r;
> >               struct { /* list_option info */
> >                       int nr;
> > +
> >                       const struct e1000_opt_list { int i; char
> *str; } *p;
> >               } l;
> >       } arg;
>=20
> How is adding a space here adding any value?  Please don't just
> blindly=20
> follow checkpatch as it can give out erroneous information.
>=20
> Looking over most of this patch series it seems like it is taking=20
> readability in the wrong direction and reducing the ability to
> maintain=20
> the driver since this code has been "maintenance only" for some time=20
> now.  If somebody comes up with a legitimate fix for an issue at some
> point in the future they will need to work around these patches in
> order=20
> to back-port it into a stable release and that just hurts
> maintainability.
>=20
> I'd say this whole series should be rejected on the grounds that this
> driver is mostly stable and should only really be modified for bug
> fixes=20
> at this point.  If we really need to go through and do a checkpatch=20
> sweep we should probably just focus on serious errors only instead of
> going astray and chasing down things that are false hits or minor
> issues=20
> that are mostly a matter of preference.

In addition to all what Alex has said, I am not pleased about a 6 patch
series, with every patch in the series with the exact same frickin
title.

Consider this patch series rejected and dropped.
--=-gm/tu2Zsz2kKGoFhgIq1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWHeolAAoJEOVv75VaS+3ORqwP/3he/9MlaLtduIroP6dSTh3u
HGcAVLxFiaBqhWpXWF78IdpVwAgpJV18QuyGriFFrKPXnCBElI5pKr7EuooGHytd
Jv4DedIcpvlBdfA2/o/17/sF/kHuqPYnnc6X9IK/qUVnp1+yGTzxtWnWELeqthRY
6DhXKCd95kRVRsGVZKU2rgUosvqSallSiDgVS11JdyIar5zDLbbI0n6FQX7f1yva
AGj0q5K2GROzoAoo5nviWX2E48tYBg+19JOBd1fhtNCRuAL5Uh8JtYdJWXl9+TOh
UejEb5NUeQhL8jJDM/LyHkl1R0vBabzrLcjsRwmSu4iqsfMFAoLTUADW4qhk2Zj9
Og5ARNArVYKRM9cr9X2e47I8cpFK7y9Kni+RfOceC2ApoSTS2TIbVn033n87uqZZ
k+SE61tKOztAmGzFtq/1/DOzPxuCtKrjuQbu74jsKrVBNTzheViQh+SmWdw2hrwB
R9XxQDTvbE1jqExM/P4pp1ORNOfuEce8CCAEF8TzdHWIUp+hzx7yM4RkvCeHp/MY
kjrxGFH2J7MqhfUys0Nk90sjGaUhIUgJEHdzg93ojlaX6GiX5tno6Cy154ZORYaC
oZ/wo+bDBb4/Z69UPrfeTPOMa1ewujWt7fzHeiSSksfyB3+t6gfTBcwPXUzTm8F7
PO2QBStq58Vcz5Y2rSay
=sNml
-----END PGP SIGNATURE-----

--=-gm/tu2Zsz2kKGoFhgIq1--
