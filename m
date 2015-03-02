From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH RFC 08/14] net: wireless: mac80211: shrink
 ieee80211_tx_info
Date: Mon, 02 Mar 2015 19:53:45 +0100
Message-ID: <1425322425.1906.4.camel@sipsolutions.net>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
	 <1425318028-26531-9-git-send-email-fw@strlen.de>
	 (sfid-20150302_184059_463522_70F2B3E8)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1425318028-26531-9-git-send-email-fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org> (sfid-20150302_184059_463522_70F2B3E8)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-03-02 at 18:40 +0100, Florian Westphal wrote:
> to make it fit into (future) 44-byte sized skb->cb[].
> 
> This works, since flags is only used to store values
> from mac80211_tx_control_flags enum, and these are just 2 bits.
> We can thus move this to the padding hole inside the union.
> 
> Also add BUILD_BUG_ON magic to make sure that the new flags
> field doesn't share storage w. other members of the union.

This is really ugly - what's the point of this?

Mind you - we are actually acutely out of space and would rather have
*more*, not less.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
