From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: [PATCH v2] wl1251: add sysfs interface for bluetooth coexistence
 mode configuration
Date: Thu, 21 Jan 2016 14:51:10 +0100
Message-ID: <20160121135110.GH7192@pali>
References: <1451130310-16666-1-git-send-email-pali.rohar@gmail.com>
 <5696D08F.9030906@broadcom.com>
 <20160114091654.GA15380@amd>
 <20160121085331.GO7192@pali>
 <87d1svyrfl.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Machek <pavel@ucw.cz>, Arend van Spriel <arend@broadcom.com>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Gnedt <david.gnedt@davizone.at>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87d1svyrfl.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 21 January 2016 15:48:14 Kalle Valo wrote:
> Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:
>=20
> > On Thursday 14 January 2016 10:16:54 Pavel Machek wrote:
> >> On Wed 2016-01-13 23:32:47, Arend van Spriel wrote:
> >> > On 12/26/2015 12:45 PM, Pali Roh=C3=A1r wrote:
> >> > >Port the bt_coex_mode sysfs interface from wl1251 driver versio=
n included
> >> > >in the Maemo Fremantle kernel to allow bt-coexistence mode conf=
iguration.
> >> > >This enables userspace applications to set one of the modes
> >> > >WL1251_BT_COEX_OFF, WL1251_BT_COEX_ENABLE and WL1251_BT_COEX_MO=
NOAUDIO.
> >> > >The default mode is WL1251_BT_COEX_OFF.
> >> > >It should be noted that this driver always enabled bt-coexisten=
ce before
> >> > >and enabled bt-coexistence directly affects the receiving perfo=
rmance,
> >> > >rendering it unusable in some low-signal situations. Especially=
 monitor
> >> > >mode is affected very badly with bt-coexistence enabled.
> >> >=20
> >> > So what user-space process will be using this interface. Did you=
 consider
> >> > adding debugfs interface? In case of monitor mode you could cons=
ider
> >> > disabling bt-coex from within the driver itself.
> >>=20
> >> This aint no debugging feature.
> >
> > Right, bt-coex is not for debugging purpose, but for normal usage, =
when
> > user want to use together bluetooth and wifi or just one of those.
>=20
> I think most of other drivers have a debugfs interface for btcoex, I
> guess mostly for testing purposes. But this really should be added to
> cfg80211.

All other TI wireless drivers have "bt_coex_state" sysfs node.

--=20
Pali Roh=C3=A1r
pali.rohar@gmail.com
