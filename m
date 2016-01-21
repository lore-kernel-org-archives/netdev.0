From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v2] wl1251: add sysfs interface for bluetooth coexistence mode configuration
Date: Thu, 21 Jan 2016 15:44:58 +0200
Message-ID: <87h9i7yrl1.fsf@kamboji.qca.qualcomm.com>
References: <1451130310-16666-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1451130310-16666-1-git-send-email-pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> ("Pali
	=?utf-8?Q?Roh=C3=A1r=22's?= message of "Sat, 26 Dec 2015 12:45:10 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Port the bt_coex_mode sysfs interface from wl1251 driver version incl=
uded
> in the Maemo Fremantle kernel to allow bt-coexistence mode configurat=
ion.
> This enables userspace applications to set one of the modes
> WL1251_BT_COEX_OFF, WL1251_BT_COEX_ENABLE and WL1251_BT_COEX_MONOAUDI=
O.
> The default mode is WL1251_BT_COEX_OFF.
> It should be noted that this driver always enabled bt-coexistence bef=
ore
> and enabled bt-coexistence directly affects the receiving performance=
,
> rendering it unusable in some low-signal situations. Especially monit=
or
> mode is affected very badly with bt-coexistence enabled.
>
> Signed-off-by: David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>
> Signed-off-by: Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> I'm resending this patch for review again as after two years there is=
 no
> nl80211 interface for bt coex and wl1251 on Nokia N900 needs it. Once
> there will be common interface for bt coex I can rewrite my patches, =
but
> I do not want to wait another 2 years...

It doesn't work like that. Wireless drivers cannot have custom
interfaces via sysfs, all configuration has to go through cfg80211.
Instead of waiting two years you could have added it yourself.

--=20
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
