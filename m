From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 16/16] wl1251: Add sysfs file address for setting
 permanent mac address
Date: Mon, 28 Oct 2013 23:50:09 +0000
Message-ID: <1383004209.3779.54.camel@bwh-desktop.uk.level5networks.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	 <1382819655-30430-17-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <freemangordon@abv.bg>,
	<aaro.koskinen@iki.fi>, <pavel@ucw.cz>, <sre@ring0.de>,
	<joni.lapilainen@gmail.com>
To: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382819655-30430-17-git-send-email-pali.rohar@gmail.com>
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
[...]

This belongs in struct wl12xx_platform_data or (better) Device Tree
properties.  It definitely should not be settable once the device is
registered.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
