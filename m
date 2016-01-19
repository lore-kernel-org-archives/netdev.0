From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/8] rfkill: Documentation and style fixes
Date: Tue, 19 Jan 2016 21:11:23 +0100
Message-ID: <1453234283.23600.5.camel@sipsolutions.net>
References: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
	 <1453218163-31998-2-git-send-email-jprvita@endlessm.com>
	 (sfid-20160119_164405_325639_90B88BB3)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org
To: =?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1453218163-31998-2-git-send-email-jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org> (sfid-20160119_164405_325639_90B88BB3)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> =C2=A0/**
> =C2=A0 * rfkill_resume_polling(struct rfkill *rfkill)
> =C2=A0 *
> - * Pause polling -- say transmitter is off for other reasons.
> + * Resume polling previously paused with rfkill_pause_polling.
> =C2=A0 * NOTE: not necessary for suspend/resume -- in that case the
> - * core stops polling anyway
> + * core restarts polling anyway, even if was explicitly paused
> + * before suspending.
> =C2=A0 */

If this is true, that's a bug, no? Drivers would call pause/resume when
their status changes, and shouldn't be required to check status at
resume time?

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
