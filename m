From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/4] generic netlink namespace awareness
Date: Sun, 12 Jul 2009 14:17:37 -0700 (PDT)
Message-ID: <20090712.141737.08152595.davem@davemloft.net>
References: <20090710195131.504091075@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tgraf-G/eBtMaohhA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090710195131.504091075-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Fri, 10 Jul 2009 21:51:31 +0200

> This patch series makes generic netlink network namespace
> aware, in some way, paving the way for making wireless
> completely netns aware (which I will submit to John's tree).
> 
> The required changes are basically some preparations in
> core netlink, a change to make it possible to iterate net
> namespaces under just RCU (which may be useful elsewhere in
> the future), the actual genetlink patch and finally also
> exporting get_net_ns_by_pid() which wireless will need.
> 
> The last patch (for get_net_ns_by_pid) could go through
> the wireless tree as well, but I've put it in here since
> it touches core code. The others probably shouldn't go
> through the wireless tree since they touch more than that.
> 
> The first patch in this series fixes the last remaining
> problem I had with the generic netlink one, the patches
> are actually unchanged from the previous submission other
> than adding patch 1 in front.

Looks good, all applied, thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
