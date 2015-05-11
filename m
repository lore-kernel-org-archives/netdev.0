From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: pull-request: mac80211-next 2015-05-06
Date: Mon, 11 May 2015 10:31:43 +0200
Message-ID: <1431333103.1964.4.camel@sipsolutions.net>
References: <1430920780.1954.10.camel@sipsolutions.net>
	 <1430920954.1954.11.camel@sipsolutions.net>
	 <20150509.172803.2129151083625591640.davem@davemloft.net>
	 <20150509.173446.1826713590855601099.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150509.173446.1826713590855601099.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-05-09 at 17:34 -0400, David Miller wrote:

> Johhannes, the hash table size Kconfig entry absolutely not appropriate.
> 
> If anything, it should be hidden behind the strongest possible "DEBUG
> ONLY" type dependencies, so that the user is never prompted for this
> confusing option.

Hmm. It's hidden behind "MAC80211_DEBUG_MENU", which already should be
discouragement, there's nothing in there that the user should ever
select unless they're developing/debugging on this.

I can word the help text more strongly, perhaps? Or make the debug menu
also depend on CONFIG_EXPERT (but most people seem to set that
anyway ...)?

I'm happy to change this, but am not entirely sure how to discourage its
use any further than we already do. Any suggestions?

johannes


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
