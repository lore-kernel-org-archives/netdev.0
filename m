From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH net-next] Allow to set net namespace for wireless device
 via RTM_LINK
Date: Mon, 20 Oct 2014 12:52:24 +0200
Message-ID: <1413802344.10246.20.camel@jlt4.sipsolutions.net>
References: <1410467723-2550-1-git-send-email-vadim4j@gmail.com>
	 <1411075535.2034.5.camel@jlt4.sipsolutions.net>
	 <20141014121627.GA5115@angus-think.lan>
	 <1413798437.10246.12.camel@jlt4.sipsolutions.net>
	 <128188DF-5A9B-47A5-8A89-974CF7CF9064@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vadim4j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <128188DF-5A9B-47A5-8A89-974CF7CF9064-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-10-20 at 12:46 +0200, Marcel Holtmann wrote:

> Maybe relaxing the check and allow ip link to move a wireless netdev
> into a namespace (and having the wiphy follow) could be allowed if it
> is the only netdev or the original wlan0 that each wiphy creates. I
> really do not know if this is worth it, but for some simpler container
> cases it could be beneficial if RTNL can be used instead of having to
> go through nl80211.

The thought crossed my mind, but

1) it's relatively complex, though by no means impossible
2) it still moves more than you bargained for, since in theory the wiphy
could be
   used to create new interfaces etc.

That said, I'm much more inclined to believe such a patch would be
worthwhile than the original.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
