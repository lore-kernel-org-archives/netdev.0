From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: fix for 82599 erratum on Header Splitting
Date: Sat, 05 Mar 2011 00:06:05 -0800
Message-ID: <1299312365.26413.35.camel@jtkirshe-MOBL1>
References: <1299308767-28735-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110305074419.GA19596@suse.de> <1299311467.26413.31.camel@jtkirshe-MOBL1>
	 <20110305075926.GA19706@suse.de>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-ZKDWAw7IV0Xh4E+agN+N"
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"stable@kernel.org" <stable@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:26185 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093Ab1CEIIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 03:08:07 -0500
In-Reply-To: <20110305075926.GA19706@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZKDWAw7IV0Xh4E+agN+N
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-03-04 at 23:59 -0800, Greg KH wrote:
> On Fri, Mar 04, 2011 at 11:51:07PM -0800, Jeff Kirsher wrote:
> > On Fri, 2011-03-04 at 23:44 -0800, Greg KH wrote:
> > > On Fri, Mar 04, 2011 at 11:06:07PM -0800, Jeff Kirsher wrote:
> > > > From: Don Skidmore <donald.c.skidmore@intel.com>
> > > >=20
> > > > We have found a hardware erratum on 82599 hardware that can lead to
> > > > unpredictable behavior when Header Splitting mode is enabled.  So
> > > > we are no longer enabling this feature on affected hardware.
> > > >=20
> > > > Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> > > > Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> > > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > > ---
> > > >  drivers/net/ixgbe/ixgbe_main.c |    4 ++++
> > >=20
> > > I'm confused, why did you just send this patch to me?
> > >=20
> > > What am I supposed to do with it?
> > >=20
> > > greg k-h
> >=20
> > This is the fix for ixgbe (that Ben and others pointed out) which has
> > been accepted into Linus's tree which did not apply to stable-2.6.32
> > tree.  This is the updated patch that apply's to the stable-2.6.32 tree=
.
>=20
> How nice, but why didn't you say so in the first place?  Am I really
> supposed to remember the hundreds of stable patches I handle every week?

Sorry, I sent you/stable an email saying that I would send you an
updated patch that would apply to stable-2.6.32.  I know you deal with a
number of patches, so I apologize.

>=20
> Oh, I need the git commit id of it as well, care to resend this with
> that and the proper "please apply this for the .32 longterm tree"
> message so I can?
>=20

Heres is the commit info:
commit a124339ad28389093ed15eca990d39c51c5736cc
Author: Don Skidmore <donald.c.skidmore@intel.com>
Date:   Tue Jan 18 22:53:47 2011 +0000


> If so, I'll queue it up for the after-next .32-longterm release.
>=20

I can resend the entire patch submission again, with the info provided,
if necessary.

> thanks,
>=20
> greg k-h



--=-ZKDWAw7IV0Xh4E+agN+N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNce7tAAoJECTsCADr/EWUIxQH/R9zvu1b5EYpJoMJJrp3h+ZI
6+TdqNBMLWhYX3BnUpqC++U2gWBqXFnpqTdu9jHSIPwlEJshbajlFEQ26YkdIqxm
VhCwEiWUehqnVVML1gsenpMfajy5kzcOjm1ASQjIRk/SVuOvEFdM8YlxExzJsTXp
dUWJ2n1CGxLY9hyu4Cldo66UgwdzgJaQZXE7NWicyo9e9nN1E8JuAYxXkKzICnCU
Hu5ZVvrCZOUsHUMoKzzimPxTxpCYEzgHeZleOmP/66kmrXIMXPzBeHSjl4tYil5O
JbjofZWyIUv/rRI/BXKMGOeQEet3P5naVb5aUCPMHgJrDRQkuliES4Mb09RYNC0=
=Q66W
-----END PGP SIGNATURE-----

--=-ZKDWAw7IV0Xh4E+agN+N--

