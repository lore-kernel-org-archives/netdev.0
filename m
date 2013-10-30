From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 02/16] wl1251: fix scan behaviour while not associated
Date: Wed, 30 Oct 2013 12:24:05 +0100
Message-ID: <20131030112405.GA8204@amd.pavel.ucw.cz>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1382819655-30430-3-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, sre@ring0.de, joni.lapilainen@gmail.com,
	David Gnedt <david.gnedt@davizone.at>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1382819655-30430-3-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat 2013-10-26 22:34:01, Pali Roh=E1r wrote:
> From: David Gnedt <david.gnedt@davizone.at>
>=20
> With a dissacociated card I often encoutered very long scan delays.
>=20
> My guess is that it has something to do with the cards DTIM handling =
and
> another firmware bug mentioned in the TI WLAN driver, which is descri=
bed as
> the card may never end scanning if the channel is overloaded because =
it
> can't send probe requests. I think the firmware somehow also tries to
> receive DTIM messages when the BSSID is not set. Therefore most of th=
e time
> it waits for DTIM messages and can't do scanning work.
>=20
> Anyway we can workaround this misbehaviour by setting the HIGH_PRIORI=
TY
> bit for scans in disassociated state.
>=20
> Signed-off-by: David Gnedt <david.gnedt@davizone.at>

I guess you should add your Signed-off-by: here (as you are sending
the patch forward).

Other than that:

Reviewed-by: Pavel Machek <pavel@ucw.cz>

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html
