From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2] wl1251: add sysfs interface for bluetooth coexistence
 mode configuration
Date: Thu, 14 Jan 2016 10:16:54 +0100
Message-ID: <20160114091654.GA15380@amd>
References: <1451130310-16666-1-git-send-email-pali.rohar@gmail.com>
 <5696D08F.9030906@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Gnedt <david.gnedt@davizone.at>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5696D08F.9030906@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed 2016-01-13 23:32:47, Arend van Spriel wrote:
> On 12/26/2015 12:45 PM, Pali Roh=E1r wrote:
> >Port the bt_coex_mode sysfs interface from wl1251 driver version inc=
luded
> >in the Maemo Fremantle kernel to allow bt-coexistence mode configura=
tion.
> >This enables userspace applications to set one of the modes
> >WL1251_BT_COEX_OFF, WL1251_BT_COEX_ENABLE and WL1251_BT_COEX_MONOAUD=
IO.
> >The default mode is WL1251_BT_COEX_OFF.
> >It should be noted that this driver always enabled bt-coexistence be=
fore
> >and enabled bt-coexistence directly affects the receiving performanc=
e,
> >rendering it unusable in some low-signal situations. Especially moni=
tor
> >mode is affected very badly with bt-coexistence enabled.
>=20
> So what user-space process will be using this interface. Did you cons=
ider
> adding debugfs interface? In case of monitor mode you could consider
> disabling bt-coex from within the driver itself.

This aint no debugging feature.
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html
