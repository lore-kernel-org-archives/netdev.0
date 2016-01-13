From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2] wl1251: add sysfs interface for bluetooth coexistence mode configuration
Date: Wed, 13 Jan 2016 14:57:16 +0200
Message-ID: <877fjdeixf.fsf@kamboji.qca.qualcomm.com>
References: <1451130310-16666-1-git-send-email-pali.rohar@gmail.com>
	<20160113121641.GM11560@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Machek <pavel@ucw.cz>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Gnedt <david.gnedt@davizone.at>
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160113121641.GM11560@pali> ("Pali =?utf-8?Q?Roh=C3=A1r=22'?=
 =?utf-8?Q?s?= message of "Wed, 13
	Jan 2016 13:16:41 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:

> On Saturday 26 December 2015 12:45:10 Pali Roh=C3=A1r wrote:
>> Port the bt_coex_mode sysfs interface from wl1251 driver version inc=
luded
>> in the Maemo Fremantle kernel to allow bt-coexistence mode configura=
tion.
>> This enables userspace applications to set one of the modes
>> WL1251_BT_COEX_OFF, WL1251_BT_COEX_ENABLE and WL1251_BT_COEX_MONOAUD=
IO.
>> The default mode is WL1251_BT_COEX_OFF.
>> It should be noted that this driver always enabled bt-coexistence be=
fore
>> and enabled bt-coexistence directly affects the receiving performanc=
e,
>> rendering it unusable in some low-signal situations. Especially moni=
tor
>> mode is affected very badly with bt-coexistence enabled.
>>=20
>> Signed-off-by: David Gnedt <david.gnedt@davizone.at>
>> Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
>> ---
>> I'm resending this patch for review again as after two years there i=
s no
>> nl80211 interface for bt coex and wl1251 on Nokia N900 needs it. Onc=
e
>> there will be common interface for bt coex I can rewrite my patches,=
 but
>> I do not want to wait another 2 years...
>>=20
>> Changes:
>> In v2 is sysfs node attached directly to wl1251 device instead of cr=
eating
>> new platform device for sysfs node. So sysfs node is now available a=
t:
>> /sys/class/net/wlan0/device/bt_coex_mode
>> ---
>>  drivers/net/wireless/ti/wl1251/acx.c    |   43 ++++++++++++++--
>>  drivers/net/wireless/ti/wl1251/acx.h    |    8 +--
>>  drivers/net/wireless/ti/wl1251/init.c   |    6 +--
>>  drivers/net/wireless/ti/wl1251/main.c   |   84 ++++++++++++++++++++=
+++++++++++
>>  drivers/net/wireless/ti/wl1251/wl1251.h |    8 +++
>>  5 files changed, 137 insertions(+), 12 deletions(-)
>
> BUMP!

Please be patient. I'm backlogged at the moment but I will get to your
patch eventually. You can follow the status from patchwork:

https://patchwork.kernel.org/project/linux-wireless/list/?state=3D*

--=20
Kalle Valo
