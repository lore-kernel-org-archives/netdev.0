From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] wireless: change cfg80211 regulatory domain info as
 debug messages
Date: Fri, 11 Dec 2015 15:26:30 +0100
Message-ID: <1449843990.2324.11.camel@sipsolutions.net>
References: <20151115073105.GA18846@dhcp-128-65.nay.redhat.com>
	 <20151115192547.3fd1b3cc@mir> <1448020533.3141.27.camel@sipsolutions.net>
	 <20151123013740.GA27383@dhcp-128-32.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefan Lippers-Hollmann <s.l-h-Mmb7MZpHnFY@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Dave Young <dyoung-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151123013740.GA27383-0VdLhd/A9PnLJg/3yGtlgR/sF2h8X+2i0E9HWUfgJXw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-11-23 at 09:37 +0800, Dave Young wrote:

> Seems there're a lot of other wireless messages. Should we refactor=20
> them as well? I still did not get chance to see where is the code.
> (My wireless driver being used is iwlwifi)

Most are probably from net/mac80211/.

> # dmesg|grep "Limiting TX power"|wc
> =C2=A0=C2=A0=C2=A04128=C2=A0=C2=A0=C2=A049600=C2=A0=C2=A0360052
>=20

I fixed this one recently, due to a bug it was printed all the time
instead of just once when taking effect.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
