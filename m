From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 16/16] wl1251: Add sysfs file address for setting
 permanent mac address
Date: Mon, 28 Oct 2013 14:45:05 +0100
Message-ID: <1382967905.17956.8.camel@jlt4.sipsolutions.net>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	 <1382819655-30430-17-git-send-email-pali.rohar@gmail.com>
	 (sfid-20131026_224040_591629_24EA42A4)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com
To: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382819655-30430-17-git-send-email-pali.rohar@gmail.com> (sfid-20131026_224040_591629_24EA42A4)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-10-26 at 22:34 +0200, Pali Roh=C3=A1r wrote:
> Driver wl1251 generating mac address randomly at startup and there is=
 no way to
> set permanent mac address via SET_IEEE80211_PERM_ADDR. This patch exp=
ort sysfs
> file which can set permanent mac address by userspace helper program.=
 Patch is
> needed for devices which do not store mac address in internal wl1251 =
eeprom.

This doesn't really seem like a good idea since you can also just use
'ip' or whatever to set the MAC address.

johannes
