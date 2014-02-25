From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: kdoc struct net_device flags and priv_flags
Date: Tue, 25 Feb 2014 13:47:09 +0000
Message-ID: <1393336029.6823.161.camel@deadeye.wl.decadent.org.uk>
References: <1393287245-4549-1-git-send-email-mcgrof@do-not-panic.com>
	 <1393294265.6823.154.camel@deadeye.wl.decadent.org.uk>
	 <20140224.235343.1936318499491821387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-mLEQHP6TvKQaei6xdEBA"
Cc: mcgrof@do-not-panic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mcgrof@suse.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140224.235343.1936318499491821387.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-mLEQHP6TvKQaei6xdEBA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-02-24 at 23:53 -0500, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Tue, 25 Feb 2014 02:11:05 +0000
>=20
> > On Mon, 2014-02-24 at 16:14 -0800, Luis R. Rodriguez wrote:
> >> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> >>=20
> >> ---
> >>  include/uapi/linux/if.h | 201 +++++++++++++++++++++++++++++++++++----=
---------
> >>  1 file changed, 149 insertions(+), 52 deletions(-)
> >>=20
> >> diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
> >> index d758163..1555623 100644
> >> --- a/include/uapi/linux/if.h
> >> +++ b/include/uapi/linux/if.h
> > [...]
> >> +/**
> >> + * enum net_device_priv_flags - &struct net_device priv_flags
> >> + *
> >> + * These are the &struct net_device, they are only set internally
> >> + * by drivers and used in the kernel but are invisible to userspace.
> > [...]
> >=20
> > Indeed, I wonder why they are in the UAPI header.  As userland doesn't
> > have a legitimate use for them, maybe you could move them back to
> > include/linux/if.h instead of bothering with adding macros?
>=20
> They are visible to userspace via sysfs.

Really, I don't see them.  Also they were renumbered a while ago (commit
080e4130b1fb) so they're not a stable interface.

> My memory may be bad, but I believe this has been brought up before.

I expect it has, yes.

Ben.

--=20
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
                                                           - Albert Einstei=
n

--=-mLEQHP6TvKQaei6xdEBA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwye3ee/yOyVhhEJAQpj0A/8D1LdK6llFmBzGyGaG4siywnsglrmGB3B
XdIiiSgdtL+WLSc+apwpZYByacDEx/FrPByIXftHKGYq7otiZKQyNezOfDDRhxeA
L5FYIGBjeZaIqdxMPXRZ7pQi93apR/qVeLql5dq+b+Nxl5WSn2szm49LMjajAyb3
A/YGKnsvKxlYA7MJxCAS0m0I6fM1j5GkUPtWZ6j0YrA5np7+1dxpUnGcnz1Pv3gp
K1hacyA1fGkFi04rSbhsgt9em/vtjR67CZi3P2KW9zTDgfoNLtXn1B4ltxXjfbj3
cLnw0GwIPhPmwITnduhr8H3coyulM2/QyBLWX84dmjkWFSksLTgGVw67/zDgXKOe
vVzgoVVMaSV4EwQsqGQ5+KMQZ++tAnzfRXpH7+lARSPcp1IkVpcTxrGN8Jgx2XG8
cVV6Vhhkf1D17e7M2jtAoNhVOwYEXmtZPz2amO1O82Sqtd7s56tzkX2A0mtJh2fo
vi4dML5SvEqZfa/tV9dBsTvXGLQkiWWGG1zoGPaWgaPkSgzL2eoLBjlZI/lT1prt
AcHxlrdqjYQAGarO7RqfIr30dtTioLNS1VjApHv5Ek9DB6TOXm/cTDKMrJiFo899
LM+XtOWeUCWOUxcCp1v9gQajqfjPyABIPdAaqsEzA0A1OWyNvMVHX0jNmq2dZGmA
+DB2+20Urfo=
=0kK7
-----END PGP SIGNATURE-----

--=-mLEQHP6TvKQaei6xdEBA--
