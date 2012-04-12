From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH 4/5] mac80211: Add more ethtools stats: survey, rates,
 etc
Date: Thu, 12 Apr 2012 20:30:53 +0100
Message-ID: <1334259053.2497.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <1334248375-22967-1-git-send-email-greearb@candelatech.com>
	 <1334248375-22967-5-git-send-email-greearb@candelatech.com>
	 <4F8705E3.2010902@openwrt.org> <4F870828.4020708@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F870828.4020708-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-04-12 at 09:51 -0700, Ben Greear wrote:
> On 04/12/2012 09:42 AM, Florian Fainelli wrote:
> > Hi,
> >
> > Le 04/12/12 18:32, greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org a =C3=A9crit :
> >> From: Ben Greear<greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
> >>
> >> The signal and noise are forced to be positive since ethtool
> >> deals in unsigned 64-bit values and this number should be human
> >> readable. This gives easy access to some of the data formerly
> >> exposed in the deprecated /proc/net/wireless file.
> >
> > Uh, that's misleading, the signal and noise values are typically ne=
gative, so one needs to think about mentally adding a minus sign if he/=
she wants to
> > understand it. Does not ethtool know about 32-bits signed integers?
>=20
> Ethtool stats only supports u64.  I think it's easy enough for
> humans or programs to add the negative sign.  Can signal or noise
> ever be > 0?  If so, that could actually break something that depends
> on flipping the value to negative....

So far as I can see, the ethtool stats were expected to be counters,
which obviously cannot become negative (or fractional).  Maybe it's tim=
e
to define another command and string-set to cover other types of status
information.  The ethtool utility could ask for those typed statistics
as well, so 'ethtool -S' would get all of them.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
