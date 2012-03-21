From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: netlink: 12 bytes leftover after parsing attributes - triggered
 by iproute2 libnetlink's rtnl_dump_request()
Date: Tue, 20 Mar 2012 17:02:29 -0700
Message-ID: <20120320170229.49de95f5@nehalam.linuxnetplumber.net>
References: <20120320134107.6acea83c@pluto.restena.lu>
	<20120320074140.39a1b3f0@nehalam.linuxnetplumber.net>
	<1332255630.8043.11.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
 boundary="Sig_/ev9tXddODV_DLHryCTDvans"; protocol="application/pgp-signature"
Cc: Bruno =?ISO-8859-1?B?UHLpbW9udA==?= <bonbons@linux-vserver.org>,
	netdev@vger.kernel.org, Greg Rose <gregory.v.rose@intel.com>
To: Ben Hutchings <ben@decadent.org.uk>,
	Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52906 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755511Ab2CUACc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2012 20:02:32 -0400
In-Reply-To: <1332255630.8043.11.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/ev9tXddODV_DLHryCTDvans
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 20 Mar 2012 15:00:30 +0000
Ben Hutchings <ben@decadent.org.uk> wrote:

> On Tue, 2012-03-20 at 07:41 -0700, Stephen Hemminger wrote:
> >=20
> > >=20
> > > Should this get fixed at kernel level, iproute2 libnetlink level or
> > > at end-user level (e.g. collectd)?
> > > Three lines every 10 seconds is a damn lot!
> > >=20
> > > Thanks,
> > > Bruno
> >=20
> > Netlink is supposed to be encoded as Type-Length-Value and correctly wr=
itten
> > programs ignore types they don't understand. So either the library is g=
etting
> > confused by the type or the attribute is not encoded correctly.
> >=20
> >=20
> > The issue could be in libnetlink library. What version of collectd and =
libnetlink
> > are you using?
>=20
> This was also reported as provoked by a client using the ntrack
> rtnetlink code: http://thread.gmane.org/gmane.linux.network/224236
>=20
> Ben.
>=20

The message "netlink: NN bytes leftover after processing attributes."
comes from libnl, not libnetlink.
The code in nla_parse() is getting confused.


--Sig_/ev9tXddODV_DLHryCTDvans
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPaRqVAAoJEICnf2CVzeR+IKEP/iDRQ6//au1WY6wFfVgQ9td8
k7wvycL/3XgiXW2imBo2sgK4RmX9nFzpTKoAaeBx/SfLpBQInsgGiEXTxZdQRPVd
NWt0pnk7q76ILVdWsWna2zbftgRk7zFqdVGLdxnm6tOl7msiM8zKlkWYu53XJXgn
/gjx6mBn6I6YI8+bvxunCrhSqQkxl+2pHI4fiRPX1dIOHrs+rJTP0WgP/i3hPJiu
dWSeZpIV540i4gMSZlgUGWKkYwriSGSy71oGy+mcfUgj5fTm2wCYURZtHUCZVhuw
Yzm3Zks40uJo2KbVJ/tA56xm4+cqJNcAiP6C2CnImMjKeDUTjCz80laI4qJrKUZj
hOLWME3J6LkjaSFbMG6Hh8qfXnAflrzL4UMto/xttajoVQqNSf20mn2tKGoiwJrI
+yyGpdDBWagkPD/WBtJbhOgjvA/nocL0TYFu6Ja71s/sm/9x4ltgfyTX5MPPhydP
hRilan+sxMtSTtUZQtVapF1AsCAukgj260AyqoeD9Zh6ihF0geXF0DD5EooOUImT
iDvWBG+qOJQDuoh4BByJt2LVz4bIyN+IrCK2FJkBhxzWa0m23BmGSMP9N+TYdPWE
uQQLAD5JfHRB8Cn8q9/bOeGPyJExz3fOGUSZCD4UU9/J3BE35ku+QTcaSkTgC7Wb
ETjgRYKlIdcwGj3GHmD6
=g5ZE
-----END PGP SIGNATURE-----

--Sig_/ev9tXddODV_DLHryCTDvans--
