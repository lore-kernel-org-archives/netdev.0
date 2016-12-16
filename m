From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Fri, 16 Dec 2016 11:40:27 +0100
Message-ID: <201612161140.27241@pali>
References: <201611111820.52072@pali> <CAB=NE6VHF+U7DzapENvLMKtN4Dgi9J0qMoeUJ8o4vSwc2-rRFQ@mail.gmail.com> <07be7fc8-6c7f-6e03-379d-fa781b248259@monom.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1686547.gFzIhqOYHO";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Tom Gundersen <teg@jklm.no>,
        Johannes Berg <johannes@sipsolutions.net>,
        Ming Lei <ming.lei@canonical.com>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        =?utf-8?q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        "linux-wireless" <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
To: Daniel Wagner <wagi@monom.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <07be7fc8-6c7f-6e03-379d-fa781b248259@monom.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1686547.gFzIhqOYHO
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Friday 16 December 2016 08:25:44 Daniel Wagner wrote:
> On 12/16/2016 03:03 AM, Luis R. Rodriguez wrote:
> > For the new API a solution for "fallback mechanisms" should be
> > clean though and I am looking to stay as far as possible from the
> > existing mess. A solution to help both the old API and new API is
> > possible for the "fallback mechanism" though -- but for that I can
> > only refer you at this point to some of Daniel Wagner and Tom
> > Gunderson's firmwared deamon prospect. It should help pave the way
> > for a clean solution and help address other stupid issues.
>=20
> The firmwared project is hosted here
>=20
> https://github.com/teg/firmwared
>=20
> As Luis pointed out, firmwared relies on
> FW_LOADER_USER_HELPER_FALLBACK, which is not enabled by default.

I know. But it does not mean that I cannot enable this option at kernel=20
compile time.

Bigger problem is that currently request_firmware() first try to load=20
firmware directly from VFS and after that (if fails) fallback to user=20
helper.

So I would need to extend kernel firmware code with new function (or=20
flag) to not use VFS and try only user mode helper.

> I
> don't see any reason why firmwared should not also support loading
> calibration data. If we find a sound way to do this.

It can, but why should I use another daemon for firmware loading as=20
non-systemd version of udev (and eudev fork) support firmware loading?=20
I think I stay with udev/eudev.

> As you can see from the commit history it is a pretty young project
> and more ore less reanimation of the old udev firmware loader
> feature.  We are getting int into shape, adding integration tests
> etc.
>=20
> The main motivation for this project is the get movement back in
> stuck discussion on the firmware loader API. Luis was very busy
> writing up all the details on the current situation and purely from
> the amount of documentation need to describe the API you can tell
> something is awry.
>=20
> Thanks,
> Daniel

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1686547.gFzIhqOYHO
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlhTxJsACgkQi/DJPQPkQ1K83wCghtlPpIAMTLQGTVn1imQwMFPW
3REAn3wCgF+Bxt3PryYCQZnDKCBkE39F
=B8/V
-----END PGP SIGNATURE-----

--nextPart1686547.gFzIhqOYHO--
