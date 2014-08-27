From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: Replace rcu_dereference() with
 rcu_access_pointer()
Date: Wed, 27 Aug 2014 12:14:23 +0200
Message-ID: <1409134463.2505.6.camel@jlt4.sipsolutions.net>
References: <20140817131801.GA24286@ada>
	 (sfid-20140817_151809_334504_0D1A926E)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: Andreea-Cristina Bernat <bernat.ada-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140817131801.GA24286@ada> (sfid-20140817_151809_334504_0D1A926E)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-08-17 at 16:18 +0300, Andreea-Cristina Bernat wrote:
> The "rcu_dereference()" calls are used directly in conditions.
> Since their return values are never dereferenced it is recommended to
> use "rcu_access_pointer()" instead of "rcu_dereference()".
> Therefore, this patch makes the replacements.

Applied, thanks.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
