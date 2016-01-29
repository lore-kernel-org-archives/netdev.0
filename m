From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: WARNING at net/mac80211/rate.c:513 ieee80211_get_tx_rates
 [mac80211]
Date: Fri, 29 Jan 2016 17:15:46 +0100
Message-ID: <1454084146.2800.0.camel@sipsolutions.net>
References: <CA+55aFxe22iWok6UojY=hCoG2k1wNpJ9CfQ0b+STSxq67tb86Q@mail.gmail.com>
	 <1453983185.2217.12.camel@sipsolutions.net>
	 <CA+55aFya9K4JboNY8kB9cg6zt9otguhdzfHm3jvLmWedxQTSWg@mail.gmail.com>
	 <1454013625.2332.9.camel@sipsolutions.net>
	 <CA+55aFx73nv9ny-fu5BR6v8wL=f2oFomwrZoLRw=x2kNP76cYA@mail.gmail.com>
	 <CA+55aFzF0gWfvmE+6ZcHmjnO4xp-oVAQ5SWxYJhOzns2ocgCsw@mail.gmail.com>
	 <1454019155.2332.15.camel@sipsolutions.net>
	 <CA+55aFxjpdepHYD_6uU48kW38Z9bmf2wwA8yPZt4ibhkofmfQA@mail.gmail.com>
	 <56AAC66C.1080800@lwfinger.net> <1454056380.3369.2.camel@sipsolutions.net>
	 <CAP71bdVZzUUNwP3py_m1pwU21qMKth=0BmMfLuUb7=B-1840zg@mail.gmail.com>
	 (sfid-20160129_171252_956705_2E9111CB)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAP71bdVZzUUNwP3py_m1pwU21qMKth=0BmMfLuUb7=B-1840zg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20160129_171252_956705_2E9111CB)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-01-29 at 10:12 -0600, Larry Finger wrote:
>=C2=A0
> Upon further inspection, my log has the line "rtl8821ae 0000:02:00.0
> wlp2s0: disabling HT/VHT due to WEP/TKIP use". I need to fix that
> first.
>=20
Likely TKIP; enable only WPA2 (CCMP) on the AP.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
