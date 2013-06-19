From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: nl80211 NULL pointer dereference
Date: Tue, 18 Jun 2013 19:06:32 -0700 (PDT)
Message-ID: <20130618.190632.33329016434510583.davem@davemloft.net>
References: <CA+55aFxOde8n0M2=77-TQ2Ea9iz8s-e8zGFwjj6RVyMFXBgxEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+55aFxOde8n0M2=77-TQ2Ea9iz8s-e8zGFwjj6RVyMFXBgxEA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date: Tue, 18 Jun 2013 15:46:13 -1000

> Hmm. Maybe this is old, but I don't think I've seen it before (who
> knows, maybe it has killed the machine before, I had a hard hang the
> other day).
> 
> It's a NULL pointer dereference in nl80211_set_reg() on my Pixel. The
> machine kind of stayed up afterwards, although with no working
> wireless, and it would not shut down cleanly presumably due to locks
> held etc.
> 
> Any ideas? I'm including the few wireless-related messages that
> happened justr before the oops. Being a pixel, this is with the ath9k
> driver.

nl80211_set_reg() is really careful about validating which netlink
attributes the user has specified, and either not dereferencing or
signalling an error when NULL is seen.

Hmmm...
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
