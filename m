From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 10/16] wl1251: fix channel switching in monitor mode
Date: Wed, 30 Oct 2013 12:47:38 +0100
Message-ID: <20131030114738.GD8763@amd.pavel.ucw.cz>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1382819655-30430-11-git-send-email-pali.rohar@gmail.com>
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
In-Reply-To: <1382819655-30430-11-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat 2013-10-26 22:34:09, Pali Roh=E1r wrote:
> From: David Gnedt <david.gnedt@davizone.at>
>=20
> Use the ENABLE_RX command for channel switching when no interface is =
present
> (monitor mode only).
> The advantage of ENABLE_RX is that it leaves the tx data path disable=
d in
> firmware, whereas the usual JOIN command seems to transmit some frame=
s at
> firmware level.
>=20
> Signed-off-by: David Gnedt <david.gnedt@davizone.at>

Missing signoff, otherwise

Reviewed-by: Pavel Machek <pavel@ucw.cz>
								Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html
