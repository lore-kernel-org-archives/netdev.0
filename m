From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Thu, 20 Sep 2012 14:47:04 +0200
Message-ID: <1348145224.4161.27.camel@jlt4.sipsolutions.net>
References: <1347361823.26457.3.camel@sauron.fi.intel.com>
	 <1DC40B07CD6EC041A66726C271A73AE6195AE9C8@IRSMSX102.ger.corp.intel.com>
	 <1347631355.5263.19.camel@sauron.fi.intel.com>
	 <1347640763.5263.24.camel@sauron.fi.intel.com>
	 <1347892887.7112.9.camel@sauron.fi.intel.com>
	 <1348142775.2388.10.camel@sauron.fi.intel.com>
	 <1348144524.4161.26.camel@jlt4.sipsolutions.net>
	 <CANn89iJkXrZPB14KU8xA-Dn8_n=H3J4-R60BTZFV+STF9_ASdA@mail.gmail.com>
	 (sfid-20120920_144027_246582_81AC7F21)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: artem.bityutskiy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CANn89iJkXrZPB14KU8xA-Dn8_n=H3J4-R60BTZFV+STF9_ASdA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20120920_144027_246582_81AC7F21)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-09-20 at 14:40 +0200, Eric Dumazet wrote:
> OK, but which netif_receive_skb(), as I count 5 occurrences in
> net/mac80211/rx.c ?

The one you modified in the other email :-)

> Instead of skb_linearize() calls
> 
> you could try several values of XXX in
> 
> pskb_may_pull(skb, XXX)
> 
> So that you make sure XXX bytes are available in skb->head, and not
> the whole frame.
> 
> One you know the limit for XXX, it might give a clue where a
> pskb_may_pull(skb, XXX) is missing.

Good idea.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
