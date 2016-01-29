From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: WARNING at net/mac80211/rate.c:513 ieee80211_get_tx_rates
 [mac80211]
Date: Fri, 29 Jan 2016 09:33:00 +0100
Message-ID: <1454056380.3369.2.camel@sipsolutions.net>
References: <CA+55aFxe22iWok6UojY=hCoG2k1wNpJ9CfQ0b+STSxq67tb86Q@mail.gmail.com>
	 <1453983185.2217.12.camel@sipsolutions.net>
	 <CA+55aFya9K4JboNY8kB9cg6zt9otguhdzfHm3jvLmWedxQTSWg@mail.gmail.com>
	 <1454013625.2332.9.camel@sipsolutions.net>
	 <CA+55aFx73nv9ny-fu5BR6v8wL=f2oFomwrZoLRw=x2kNP76cYA@mail.gmail.com>
	 <CA+55aFzF0gWfvmE+6ZcHmjnO4xp-oVAQ5SWxYJhOzns2ocgCsw@mail.gmail.com>
	 <1454019155.2332.15.camel@sipsolutions.net>
	 <CA+55aFxjpdepHYD_6uU48kW38Z9bmf2wwA8yPZt4ibhkofmfQA@mail.gmail.com>
	 <56AAC66C.1080800@lwfinger.net> (sfid-20160129_025456_485103_1633A2EE)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56AAC66C.1080800-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> (sfid-20160129_025456_485103_1633A2EE)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-01-28 at 19:54 -0600, Larry Finger wrote:
>=C2=A0
> I have been running an RTL8821AE since kernel 3.18 without hitting
> this problem=20
> using a TRENDnet AC1750 dual-band AP. The UniFi may be doing
> something that the=20
> driver is not expecting.

Are you quite sure you're actually using VHT though, perhaps the AP
somehow turned it off? It seems unlikely that you could successfully
use it in any way given that=C2=A0RATE_INFO_FLAGS_VHT_MCS doesn't show =
up in
the driver or rate scaling at all.


johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
