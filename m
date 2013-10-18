From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 00/23 v2] cleanup: introduce
 br/netdev/netif/wiphy_<foo>_ratelimited() and use them to simplify code
Date: Thu, 17 Oct 2013 21:11:22 -0700
Message-ID: <1382069482.22110.164.camel@joe-AO722>
References: <1382068363-10088-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kefeng Wang <wangkefeng.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1382068363-10088-1-git-send-email-wangkefeng.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(resending to lists only because of multiple X's in the subject line)

On Fri, 2013-10-18 at 11:52 +0800, Kefeng Wang wrote:
> v1-v2:
> 
>   Introduce macro br/netdev/netif/wiphy_XXX_ratelimited() according
>   to Joe Perches's advice. The macros are similar to net_XXX_ratelimited()
>   which is more clarifying than net_ratelimited_function(), then use them
>   to simplify code.

There are some conceptual differences between these
implementations and other <foo>_ratelimited uses.

For every other subsystem but net, there is a per-location
struct ratelimit_state.

Here you've made the global net_ratelimit_state replace all
of these individual structs so there is some new interaction.

Dunno if that's good or bad.



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
