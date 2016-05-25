From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RESEND] Re: updating carl9170-1.fw in linux-firmware.git
Date: Wed, 25 May 2016 15:51:14 +0100
Message-ID: <1464187874.2762.18.camel@decadent.org.uk>
References: <20160416113312.8de2266358165182bb4b4a15@gmx.com>
	 <11418613.XH7h8m2RjK@debian64> <87a8koiubz.fsf@kamboji.qca.qualcomm.com>
	 <2185358.G319l0XIJC@debian64>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-aVguvMqGs0TR7FTSzLqi"
Cc: Lauri Kasanen <cand@gmx.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linux Firmware Maintainers <linux-firmware@kernel.org>,
	Xose Vazquez Perez <xose.vazquez@gmail.com>
To: Christian Lamparter <chunkeey@googlemail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2185358.G319l0XIJC@debian64>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-aVguvMqGs0TR7FTSzLqi
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-04-20 at 23:11 +0200, Christian Lamparter wrote:
> On Wednesday, April 20, 2016 10:59:44 AM Kalle Valo wrote:
> > Christian Lamparter <chunkeey@googlemail.com> writes:
> >=20
> > > On Monday, April 18, 2016 07:42:05 PM Kalle Valo wrote:
> > > > Christian Lamparter <chunkeey@googlemail.com> writes:
> > > >=20
> > > > > On Monday, April 18, 2016 06:45:09 PM Kalle Valo wrote:
> > > > >=20
> > > > > > Why even mention anything about a "special firmware" as the fir=
mware is
> > > > > > already available from linux-firmware.git?=C2=A0
> > > > >=20
> > > > > Yes and no. 1.9.6 is in linux-firmware.git. I've tried to add 1.9=
.9 too
> > > > > but that failed.
> > > > >=20
> > > >=20
> > > > Rick's comment makes sense to me, better just to provide the latest
> > > > version. No need to unnecessary confuse the users. And if someone r=
eally
> > > > wants to use an older version that she can retrieve it from the git
> > > > history.
> > >=20
> > > Part of the fun here is that firmware is GPLv2. The linux-firmware.gi=
t has
> > > to point to or add the firmware source to their tree. They have added=
 every
> > > single source file to it.... instead of "packaging" it in a tar.bz2/g=
z/xz
> > > like you normally do for release sources.
> > >=20
> > > If you want to read more about it:
> > > <http://www.spinics.net/lists/linux-wireless/msg101868.html>
> >=20
> > Yeah, that's more work. I get that. But I'm still not understanding
> > what's the actual problem which prevents us from updating carl9170
> > firmware in linux-firmware.
> I'm not sure, but why not ask? I've added the cc'ed Linux Firmware
> Maintainers. So for those people reading the fw list:
>=20
> What would it take to update the carl9170-1.fw firmware file in your
> repository to the latest version?
>=20
> Who has to sent the firmware update. Does it have to be the person who
> sent the first request? (Xose)? The maintainer of the firmware (me)?
> someone from Qualcomm Atheros? Or someone else (specific)? (the=C2=A0
> firmware is licensed as GPLv2 - in theory anyone should be able to
> do that)

Given the licence, I don't particularly care.

> How should the firmware source update be handled? Currently the latest
> .tar.xz of the firmware has ~130kb. The formated patches from 1.9.6 to
> latest are about ~100kb (182 individual patches).

Either patches that 'git am' can handle, or a git branch.

> How does linux-firmware handle new binary firmware images and new=C2=A0
> sources? What if carl9170fw-2.bin is added. Do we need another
> source directory for this in the current tree then? Because=C2=A0
> carl9170fw-1.bin will still be needed for backwards compatibility
> so we basically need to duplicate parts of the source?

We still need to include the old binary for compatibility, and the old
source for GPL compliance. =C2=A0(If there was a source version that could
build firmware for both ABI versions, then we could update both
binaries and have one set of source files. =C2=A0But it doesn't sound like
that's the case.)

> Also, how's the situation with ath9k_htc? The 1.4.0 image contains
> some GPLv2 code as well?

I didn't realise that.

> So, why is there no source in the tree, but=C2=A0just the link to it?

An oversight which we need to fix.

> Because, I would like to do basically the same
> for carl9170fw and just add a link to the carl9170fw repository and
> save everyone this source update "song and dance".

Merely linking to upstream source doesn't satisfy GPLv2 source
requirements, at least not in case of commercial distribution. =C2=A0Linux
distributors should be able to use a snapshot of linux-firmware as the
upstream source for a package, without worrying about whether there are
extra sources they need to include.

(I'm aware that there are several files that don't actually have clear
licences for. =C2=A0But those are at least called out in WHENCE, and were
previously distributed as part of the kernel sources for years.)

Ben.

--=20
Ben Hutchings
Time is nature's way of making sure that everything doesn't happen at
once.

--=-aVguvMqGs0TR7FTSzLqi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXRbviAAoJEOe/yOyVhhEJKU0P/0KwlFF1GiMaJM03AnQxhJnY
Rf2GbVfIwy1T6vNF+iL+XOnNVI6lpxoyIi5kwa9lMW6IK9eDsD4PckpYIWvCgPSk
Q96YuOpsF5G0MUIkJSJQeyY4E29+RS3uh9Nh9mF2Bjm1nbZdHVlY+ZU4sdCrVfLu
lc2t+xhGw+97Mmk6w8jnvdaWNH9nBT6OcIBZ9ZUJUYmNysee4B5NzCRuzUq2fDBI
AjcQqgHPJo95AAbLv56xny79Ecxv+p1tSIvQ5CFevYude7frbDBH/+QaIxgnrJtW
otAFuNoJ090qYF54mOUgCMwqft0Ji2qlBxKiapIUIzZ+2T/M6n3e3n7r2Q00RaKf
UCRtJ0B9HujSDeGNftzq+V4YDsTNG5WQ6K0rCiqZTYc81xi3bMKszzhT7ZDbSsHF
9c0KFP6d6ZvOKl4olsWANKqBLuu7gTOi/BkZQbqNKKS7VcveyPq9XfJwNTB/9F6/
tS+Eux0nsvh77J6ahI/1FwstPUDu7ssFFzWdPhytWDrcankM/V+J1XqPom3j/xUv
A2cXW67Lm3FqKzcmbNvAMRevV9HkhoDRcx9fFvb0ca7nYTGcWNM55qV9FUqgYC4V
9/rGdkIg0gzH1g0RB7I+UzBQXPmvQGPIAZWF/t5r8Sh3/wiJEvjHsrlNAcIK7BnI
gCsIDmJhDzi7dj84HsD9
=lKd7
-----END PGP SIGNATURE-----

--=-aVguvMqGs0TR7FTSzLqi--
