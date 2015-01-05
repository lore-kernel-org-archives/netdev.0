From: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Subject: Re: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Mon, 05 Jan 2015 23:05:19 +0100
Message-ID: <1420495519.14308.29.camel@x220>
References: <1420297188.2397.3.camel@tiscali.nl>
	 <CD467A59-F563-439B-BA82-954AB27AD9CC@holtmann.org>
	 <CA+55aFzYSiUkntraMrHEhMzkt35Ft2p9E3cT7ejwQOBDwKvcOg@mail.gmail.com>
	 <1420324124.9624.60.camel@x220> <54AA641C.7050307@broadcom.com>
	 <1420479510.14308.23.camel@x220>
	 (sfid-20150105_183907_807502_81C08416) <1420484224.9459.16.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420484224.9459.16.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-01-05 at 19:57 +0100, Johannes Berg wrote:
> Multiple other groups of ioctls could be converted in similar patches,
> until at the end you can completely remove ipw_wx_handlers and rely
> entirely on cfg80211's wext compatibility.
> 
> So far the theory - in practice nobody cared enough to start working on
> any of these drivers, let alone actually has the hardware today.

So my suggestion to make ipw2200 no longer use cfg80211_wext_giwname()
would actually be backwards. What's actually needed, in theory, is to
use more of what's provided under CFG80211_WEXT (and, I guess, less of
what's provided under WIRELESS_EXT). Did I get that right?

Thanks,


Paul Bolle

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
