From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: port CCMP to cryptoapi's CCM driver
Date: Tue, 08 Oct 2013 14:16:04 +0200
Message-ID: <1381234564.13359.11.camel@jlt4.sipsolutions.net>
References: <1381231915-24232-1-git-send-email-ard.biesheuvel@linaro.org>
	 <1381233152.13359.10.camel@jlt4.sipsolutions.net>
	 <CAKv+Gu9-ddqyuGg=NDFoWzNko+0uMG_po6WnzTc7g3DAzx=_dQ@mail.gmail.com>
	 (sfid-20131008_140033_095639_86E4390E)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Patch Tracking <patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKv+Gu9-ddqyuGg=NDFoWzNko+0uMG_po6WnzTc7g3DAzx=_dQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20131008_140033_095639_86E4390E)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-10-08 at 14:00 +0200, Ard Biesheuvel wrote:

> BTW I should probably have mentioned that this is fully tested code:
> my zd1211 works happily with it using pairwise CCMP with no
> regressions in performance.

Good to know. Not that I think zd1211 is a good device for performance
tests (you'd have to measure CPU utilisation in some way), but
ultimately it doesn't really matter as all the high-performance devices
need hardware crypto anyway.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
