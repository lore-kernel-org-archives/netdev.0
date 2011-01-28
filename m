From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/2] net/wireless/nl80211.c: Avoid call to
 genlmsg_cancel
Date: Fri, 28 Jan 2011 15:20:05 +0100
Message-ID: <1296224405.5118.8.camel@jlt3.sipsolutions.net>
References: <1296224232-8115-1-git-send-email-julia@diku.dk>
	 <1296223267.5118.7.camel@jlt3.sipsolutions.net>
	 <Pine.LNX.4.64.1101281515410.8546@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.1101281515410.8546-h8frIrHk2441Y/6SN6b7/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-01-28 at 15:16 +0100, Julia Lawall wrote:

> > But why did you call the label differently? :)
> 
> Because out is already used in this case, and I didn't want to change all 
> of the other occurrences of nla_put_failure.  It's a bit sloppy though, 
> because this code is the actual nla_put_failure.  I can change it if you 
> prefer.

Oh, and I could've seen that from the patch itself too, I just missed
it, sorry.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
