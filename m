From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v2] wl1251: add sysfs interface for bluetooth coexistence mode configuration
Date: Thu, 21 Jan 2016 16:44:33 +0200
Message-ID: <871t9byotq.fsf@kamboji.qca.qualcomm.com>
References: <1451130310-16666-1-git-send-email-pali.rohar@gmail.com>
	<5696D08F.9030906@broadcom.com> <20160114091654.GA15380@amd>
	<20160121085331.GO7192@pali> <87d1svyrfl.fsf@kamboji.qca.qualcomm.com>
	<20160121135110.GH7192@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160121135110.GH7192@pali> ("Pali =?utf-8?Q?Roh=C3=A1r=22's?=
 message of "Thu, 21
	Jan 2016 14:51:10 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Thursday 21 January 2016 15:48:14 Kalle Valo wrote:
>> Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>=20
>> > On Thursday 14 January 2016 10:16:54 Pavel Machek wrote:
>> >> On Wed 2016-01-13 23:32:47, Arend van Spriel wrote:
>> >> > On 12/26/2015 12:45 PM, Pali Roh=C3=A1r wrote:
>> >> > >Port the bt_coex_mode sysfs interface from wl1251 driver versi=
on included
>> >> > >in the Maemo Fremantle kernel to allow bt-coexistence mode con=
figuration.
>> >> > >This enables userspace applications to set one of the modes
>> >> > >WL1251_BT_COEX_OFF, WL1251_BT_COEX_ENABLE and WL1251_BT_COEX_M=
ONOAUDIO.
>> >> > >The default mode is WL1251_BT_COEX_OFF.
>> >> > >It should be noted that this driver always enabled bt-coexiste=
nce before
>> >> > >and enabled bt-coexistence directly affects the receiving perf=
ormance,
>> >> > >rendering it unusable in some low-signal situations. Especiall=
y monitor
>> >> > >mode is affected very badly with bt-coexistence enabled.
>> >> >=20
>> >> > So what user-space process will be using this interface. Did yo=
u consider
>> >> > adding debugfs interface? In case of monitor mode you could con=
sider
>> >> > disabling bt-coex from within the driver itself.
>> >>=20
>> >> This aint no debugging feature.
>> >
>> > Right, bt-coex is not for debugging purpose, but for normal usage,=
 when
>> > user want to use together bluetooth and wifi or just one of those.
>>=20
>> I think most of other drivers have a debugfs interface for btcoex, I
>> guess mostly for testing purposes. But this really should be added t=
o
>> cfg80211.
>
> All other TI wireless drivers have "bt_coex_state" sysfs node.

Then that's a mistake, they shouldn't have that.

--=20
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
