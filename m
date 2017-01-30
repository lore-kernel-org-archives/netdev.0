From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for loading NVS calibration data
Date: Mon, 30 Jan 2017 19:03:01 +0100
Message-ID: <201701301903.02043@pali>
References: <def4c357-64c0-0681-a5d5-f49a6cb84a92@broadcom.com> <20170127194012.GE20571@amd> <20170130175309.GY7403@atomide.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1794404.FCbjbtiOYb";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>, Kalle Valo <kvalo@codeaurora.org>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170130175309.GY7403@atomide.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1794404.FCbjbtiOYb
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday 30 January 2017 18:53:09 Tony Lindgren wrote:
> * Pavel Machek <pavel@ucw.cz> [170127 11:41]:
> > On Fri 2017-01-27 17:23:07, Kalle Valo wrote:
> > > Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:
> > > > On Friday 27 January 2017 14:26:22 Kalle Valo wrote:
> > > >> Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:
> > > >> > 2) It was already tested that example NVS data can be used
> > > >> > for N900 e.g. for SSH connection. If real correct data are
> > > >> > not available it is better to use at least those example
> > > >> > (and probably log warning message) so user can connect via
> > > >> > SSH and start investigating where is problem.
> > > >>=20
> > > >> I disagree. Allowing default calibration data to be used can
> > > >> be unnoticed by user and left her wondering why wifi works so
> > > >> badly.
> > > >=20
> > > > So there are only two options:
> > > >=20
> > > > 1) Disallow it and so these users will have non-working wifi.
> > > >=20
> > > > 2) Allow those data to be used as fallback mechanism.
> > > >=20
> > > > And personally I'm against 1) because it will break wifi
> > > > support for *all* Nokia N900 devices right now.
> > >=20
> > > All two of them? :)
> >=20
> > Umm. You clearly want a flock of angry penguins at your doorsteps
> > :-).
>=20
> Well this silly issue of symlinking and renaming nvs files in a
> standard Linux distro was also hitting me on various devices with
> wl12xx/wl18xx trying to use the same rootfs.

wl12xx/wl18xx have probably exactly same problem as wl1251.

> Why don't we just set a custom compatible property for n900 that then
> picks up some other nvs file instead of the default?

But that still does not solve this problem correctly. Every n900 device=20
have different NVS file. If we allow to load firmware directly from VFS=20
without userspace helper we would see again same problem.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1794404.FCbjbtiOYb
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAliPf9YACgkQi/DJPQPkQ1JbCQCgzTXVLMnh/oT3/hxkmso53HTS
oIcAnRVQbs50sOAxgZxD+5flps5f44O7
=6Ie3
-----END PGP SIGNATURE-----

--nextPart1794404.FCbjbtiOYb--
