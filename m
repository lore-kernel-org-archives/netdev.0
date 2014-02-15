From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Drivers: net: wireless: mac80211_hwim fixed coding
 style issues
Date: Sat, 15 Feb 2014 19:13:50 +0100
Message-ID: <1392488030.4298.5.camel@jlt4.sipsolutions.net>
References: <1392465312-3780-1-git-send-email-justinvanwijngaarden@gmail.com>
	 (sfid-20140215_125633_755512_88424C91)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: Justin van Wijngaarden <justinvanwijngaarden@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392465312-3780-1-git-send-email-justinvanwijngaarden@gmail.com> (sfid-20140215_125633_755512_88424C91)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-02-15 at 12:55 +0100, Justin van Wijngaarden wrote:

> @@ -1,19 +1,17 @@
> -/*
> - * mac80211_hwsim - software simulator of 802.11 radio(s) for mac80211
> +/* mac80211_hwsim - software simulator of 802.11 radio(s) for mac80211

I don't see any point in this - lots of code exists both ways, that's
really just fluff. The difference isn't even interesting enough to be
worth fixing up.

>   * published by the Free Software Foundation.
> - */
> +*/

That's just wrong.

In any case, your patch won't apply anyway since we've since
changed/removed code that you're modifying.

There's very little in this patch that I'd be willing to apply, and most
of that you actually got the coding style wrong so it's not an
improvement at all.

johannes
