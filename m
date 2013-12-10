From: Kalle Valo <kvalo@adurom.com>
Subject: Re: [PATCH v2 15/16] wl1251: Add sysfs file address for setting permanent mac address
Date: Tue, 10 Dec 2013 17:49:23 +0200
Message-ID: <87txegpuyk.fsf@purkki.adurom.net>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	<1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
	<1386494714-21070-16-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386494714-21070-16-git-send-email-pali.rohar@gmail.com>
 ("Pali
	=?utf-8?Q?Roh=C3=A1r=22's?= message of "Sun, 8 Dec 2013 10:25:13 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:

> Driver wl1251 generating mac address randomly at startup and there is=
 no way to
> set permanent mac address via SET_IEEE80211_PERM_ADDR. This patch exp=
ort sysfs
> file which can set permanent mac address by userspace helper program.=
 Patch is
> needed for devices which do not store mac address in internal wl1251 =
eeprom.
>
> Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>

We have ioctl() command for setting the mac address.

--=20
Kalle Valo
