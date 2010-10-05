From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/4] genetlink: introduce pre_doit/post_doit hooks
Date: Tue, 05 Oct 2010 00:08:50 -0700 (PDT)
Message-ID: <20101005.000850.241436160.davem@davemloft.net>
References: <20101004191402.183055479@sipsolutions.net>
	<20101004191838.763690480@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101004191838.763690480-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Mon, 04 Oct 2010 21:14:03 +0200

> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> Each family may have some amount of boilerplate
> locking code that applies to most, or even all,
> commands.
> 
> This allows a family to handle such things in
> a more generic way, by allowing it to
>  a) include private flags in each operation
>  b) specify a pre_doit hook that is called,
>     before an operation's doit() callback and
>     may return an error directly,
>  c) specify a post_doit hook that can undo
>     locking or similar things done by pre_doit,
>     and finally
>  d) include two private pointers in each info
>     struct passed between all these operations
>     including doit(). (It's two because I'll
>     need two in nl80211 -- can be extended.)
> 
> Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
