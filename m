From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Sat, 3 Jan 2015 10:02:00 -0800
Message-ID: <CD467A59-F563-439B-BA82-954AB27AD9CC@holtmann.org>
References: <1420297188.2397.3.camel@tiscali.nl>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420297188.2397.3.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

> This reverts commit dddd60220f41775e634258efd1b54c6fa81ce706.
>=20
> The raison d'=C3=AAtre of commit dddd60220f41 ("ipw2200: select
> CFG80211_WEXT") was reverted in commit 2d36e008739e ("Revert "cfg8021=
1:
> make WEXT compatibility unselectable""). So revert this commit too.
>=20
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
> drivers/net/wireless/ipw2x00/Kconfig | 3 +--
> 1 file changed, 1 insertion(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/wireless/ipw2x00/Kconfig b/drivers/net/wirel=
ess/ipw2x00/Kconfig
> index 21de4fe6cf2d..91c0cb3c368e 100644
> --- a/drivers/net/wireless/ipw2x00/Kconfig
> +++ b/drivers/net/wireless/ipw2x00/Kconfig
> @@ -65,8 +65,7 @@ config IPW2100_DEBUG
>=20
> config IPW2200
> 	tristate "Intel PRO/Wireless 2200BG and 2915ABG Network Connection"
> -	depends on PCI && CFG80211
> -	select CFG80211_WEXT
> +	depends on PCI && CFG80211 && CFG80211_WEXT
> 	select WIRELESS_EXT
> 	select WEXT_SPY
> 	select WEXT_PRIV

why would you revert this? It is obviously the correct change to actual=
ly select CFG80211_WEXT.

Regards

Marcel
