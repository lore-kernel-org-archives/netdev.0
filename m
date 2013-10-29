From: Kalle Valo <kvalo@adurom.com>
Subject: Re: [PATCH 03/16] wl1251: add sysfs interface for bluetooth coexistence mode configuration
Date: Tue, 29 Oct 2013 15:35:20 +0200
Message-ID: <878uxctd2f.fsf@purkki.adurom.net>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	<1382819655-30430-4-git-send-email-pali.rohar@gmail.com>
	<1383003587.3779.49.camel@bwh-desktop.uk.level5networks.com>
	<1383030565.21526.92.camel@porter.coelho.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com, David Gnedt <david.gnedt@davizone.at>
To: Luca Coelho <luca@coelho.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383030565.21526.92.camel@porter.coelho.fi> (Luca Coelho's
	message of "Tue, 29 Oct 2013 09:09:25 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luca Coelho <luca@coelho.fi> writes:

> On Mon, 2013-10-28 at 23:39 +0000, Ben Hutchings wrote:
>> On Sat, 2013-10-26 at 22:34 +0200, Pali Roh=C3=A1r wrote:
>> > From: David Gnedt <david.gnedt@davizone.at>
>> >=20
>> > Port the bt_coex_mode sysfs interface from wl1251 driver version i=
ncluded
>> > in the Maemo Fremantle kernel to allow bt-coexistence mode configu=
ration.
>> > This enables userspace applications to set one of the modes
>> > WL1251_BT_COEX_OFF, WL1251_BT_COEX_ENABLE and WL1251_BT_COEX_MONOA=
UDIO.
>> > The default mode is WL1251_BT_COEX_OFF.
>> > It should be noted that this driver always enabled bt-coexistence =
before
>> > and enabled bt-coexistence directly affects the receiving performa=
nce,
>> > rendering it unusable in some low-signal situations. Especially mo=
nitor
>> > mode is affected very badly with bt-coexistence enabled.
>> [...]
>>=20
>> This should be implemented consistently with other drivers:
>>=20
>> drivers/net/wireless/ath/ath9k/htc_drv_init.c:module_param_named(btc=
oex_enable, ath9k_htc_btcoex_enable, int, 0444);
>> drivers/net/wireless/ath/ath9k/init.c:module_param_named(btcoex_enab=
le, ath9k_btcoex_enable, int, 0444);
>> drivers/net/wireless/b43/main.c:module_param_named(btcoex, modparam_=
btcoex, int, 0444);
>> drivers/net/wireless/ipw2x00/ipw2200.c:module_param(bt_coexist, int,=
 0444);
>> drivers/net/wireless/iwlegacy/common.c:module_param(bt_coex_active, =
bool, S_IRUGO);
>> drivers/net/wireless/iwlwifi/iwl-drv.c:module_param_named(bt_coex_ac=
tive, iwlwifi_mod_params.bt_coex_active,
>> drivers/net/wireless/ti/wlcore/sysfs.c:static DEVICE_ATTR(bt_coex_st=
ate, S_IRUGO | S_IWUSR,
>>=20
>> Oh, hmm, I see a problem here.
>
> With so many drivers doing the same thing, isn't it about time to add
> this to nl80211?

Yes, this really needs to be in nl80211. I even suggested this years ag=
o
but was turned down at the time. Can't remember the reason anymore.

--=20
Kalle Valo
