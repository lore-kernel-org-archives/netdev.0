From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
 2014-10-23
Date: Fri, 24 Oct 2014 13:45:50 -0700
Message-ID: <1414183550.2366.24.camel@jtkirshe-mobl>
References: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20141024.164327.535125094046571848.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dqfaEIhQIKAv/R9/D9QS"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50189 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752682AbaJXUp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 16:45:56 -0400
In-Reply-To: <20141024.164327.535125094046571848.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dqfaEIhQIKAv/R9/D9QS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-10-24 at 16:43 -0400, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 23 Oct 2014 21:09:57 -0700
>=20
> > This series contains updates to i40e and i40evf.
> >=20
> > Jesse modifies the i40e driver to only notify the firmware on link up/d=
own
> > and qualified module events.  Also simplified the job of managing link
> > state by using the admin queue receive event for link events as a signa=
l
> > to tell the driver to update link state.
> >=20
> > Jeff (me) cleans up the inconsistent use of tabs for indentation in the=
 admin
> > queue command header file.
> >=20
> > Neerav converts the use of udelay() to usleep_range().
> >=20
> > Anjali fixes a bug where receive would stop after some stress by adding
> > a sleep and restart as well as moving the setting of flow control becau=
se
> > it should be done at a PF level and not a VSI level.
> >=20
> > Mitch adds code to handle link events when updating the PF switch, whic=
h
> > allows link information to be properly provided to VFS in all cases.
> >=20
> > Catherine adds driver support for 10GBaseT and bumps driver version.
>=20
> I've pulled, but I absolutely don't like that change that moved the
> variables out of the loop.
>=20
> Putting variables in the inner-most scope of their use is always the
> best choice because:
>=20
> 1) Auditing is easier, because you are constraining the scope in
>    which you have to check if the variable is setup properly
>    before it is used.
>=20
> 2) You are helping the compiler out, because you have done the
>    majority of solving the graph coloring problem for it and the
>    compiler therefore has less work to do.
>=20
> Please don't make changes like this in the future, and instead do the
> opposite, by moving more variable declarations into their innermost
> possible scope.
>=20
> Thanks.

Noted, and I have forwarded on your request on to the team so that we
are all on the same page.

--=-dqfaEIhQIKAv/R9/D9QS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUSrp+AAoJEOVv75VaS+3O86QQAKau782F8H7s/Jti6Iu1LJS9
dz41AnFik+kF9Mv6owrBffrEEBIVtawKMR2BL7ez3ZTpFl0sZwI8IGkzHGWiV0la
Okj4DRQDLGfb4FYnm7Z7OevxVxYD+Jyc8ktXxAugu6s05RbfZ1HSjrvfDONVHzbO
ALuNVAYpFP0fKlbA37zBgRL6NEfLZQnPBncglmsT7VFixqCf/xcbSMAV7aaH56YX
vj2fmS+WLNUv4bol0+FreRTOdTJb2RJYfBIhDAw48l2wBQx7yiE9io7SIEVFW27n
N/trmF9iGIU39mCLr8y2jWHi9mrk6E0qr0byrvx/eQl40ZJXm64ZxB+tPDg4zQEE
dWDH52QLL8yFJ4itWSXEpzhGqoi1LeFA1f4FUuOKxp7+THXlhabykrCG1FHKMmxV
IHlPpd58Sb9jTMWLnqRXnNl2jZXEmsJeZM2G8pAGL9t25UN7aWk4Kuq4ejjgstxV
RlK0TiOsRfFfvxArcCMZbanJD1H38+Ey+/7PJD8UPrAKR+IzAOvWiYxLwVTIZSLG
jDcJx7jRMdIv2yTYAR3004Af61X3aPUoYtZq+HumxDPG1M22cxqHIdRG57Ndy9vY
FpGXOnzjqrBR2jywSh/oBw65Pcv3cEHigwXZeZPy0i1iXCBQ+8ZuGKxh6WKOoWVf
OG9awdYzy5UqU6WWUaDB
=3+bI
-----END PGP SIGNATURE-----

--=-dqfaEIhQIKAv/R9/D9QS--
