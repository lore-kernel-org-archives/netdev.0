From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 4/6] wl1251: Generate random MAC address only if driver does not have valid
Date: Sat, 24 Dec 2016 19:38:44 +0100
Message-ID: <201612241938.45077@pali>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com> <1482598381-16513-5-git-send-email-pali.rohar@gmail.com> <20161224180854.GB13590@amd>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1531826.n4WbykfFOs";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161224180854.GB13590@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1531826.n4WbykfFOs
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Saturday 24 December 2016 19:08:54 Pavel Machek wrote:
> On Sat 2016-12-24 17:52:59, Pali Roh=C3=A1r wrote:
> > Before this patch driver generated random MAC address every time
> > when was doing initialization. And after that random MAC address
> > could be overwritten with fixed one if provided.
>=20
> Before this patch, driver generated random MAC address every time it
> was initialized. After that random MAC address could be overwritten
> with fixed one, if provided.
>=20
> > This patch changes order. First it tries to read fixed MAC address
> > and if it fails then driver generates random MAC address.
>=20
> I don't quite get where the advantage is supposed to be. Is it that
> "use_eeprom" is set, but reading fails?

Random bytes are read from kernel only if random MAC address is needed.=20
And in wl->mac_addr is always either invalid address or permanenent mac=20
address which will be used. Without patch in wl->mac_addr can be random=20
temporary address for some time...

> The only case where this helps is if wl1251_read_eeprom_mac()
> succeeds but reads invalid address.
>=20
> > Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
>=20
> Acked-by: Pavel Machek <pavel@ucw.cz>

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1531826.n4WbykfFOs
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlhewLUACgkQi/DJPQPkQ1IYugCfSB1Le1TJ5Wgbi54C0Oz6W3E8
p14An1s1w7G+qTRZdwSAEC3jO5fBBwC+
=oBOF
-----END PGP SIGNATURE-----

--nextPart1531826.n4WbykfFOs--
