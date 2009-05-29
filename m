From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 0/10]: Kill more direct references to SKB list
 implementation.
Date: Fri, 29 May 2009 01:39:58 -0700 (PDT)
Message-ID: <20090529.013958.241541251.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


This is some more work towards eliminating exlicit references to the
SKB list implementation, with the eventual goal that converting the
tree over to use "struct list_head" for skb's can be a single commit
to just one file, linux/skbuff.h

In order for that to happen, sufficient abstract interfaces need to
exist in linux/skbuff.h (that's already mostly the case) and code
needs to use those interfaces instead of directly hitting skb->next,
skb->prev, comparing such pointers to the list head with a cast, etc.

There's still a bit more to do, but we're closer than ever to being
able to put the last nail in the coffin on this one.

I'll be pushing these out to net-next-2.6 after some sanity build
checks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
