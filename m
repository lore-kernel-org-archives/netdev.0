From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: net-core-rtnetlinkc-copy-paste-error-in-rtnl_bridge_notify.patch
Date: Thu, 03 Apr 2014 21:47:58 +0200
Message-ID: <533DBAEE.8060605@redhat.com>
References: <20140403120122.fe50ce80260faf3fc3a4ae30@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26285 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753371AbaDCTsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2014 15:48:11 -0400
In-Reply-To: <20140403120122.fe50ce80260faf3fc3a4ae30@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/2014 09:01 PM, Andrew Morton wrote:
> Guys, I've been sitting on this since January and simply cannot
> remember what happened with it.  Is this still a thing or did it get
> nacked, or...?

http://thread.gmane.org/gmane.linux.kernel/1638261/focus=1642371

I think someone should add a comment to this code line stating that
this is intentional ... :)

> Thanks.
>
> From: Yogesh Gaur <yogeshgaur.83@gmail.com>
> Subject: net/core/rtnetlink.c: copy paste error in rtnl_bridge_notify()
>
> Seems to be copy paste error in calling ndo_bridge_getlink() func.
>
> Signed-off-by: Yogesh Gaur <yogeshgaur.83@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>   net/core/rtnetlink.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff -puN net/core/rtnetlink.c~net-core-rtnetlinkc-copy-paste-error-in-rtnl_bridge_notify net/core/rtnetlink.c
> --- a/net/core/rtnetlink.c~net-core-rtnetlinkc-copy-paste-error-in-rtnl_bridge_notify
> +++ a/net/core/rtnetlink.c
> @@ -2576,7 +2576,7 @@ static int rtnl_bridge_notify(struct net
>
>   	if ((!flags || (flags & BRIDGE_FLAGS_MASTER)) &&
>   	    br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {
> -		err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
> +		err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, br_dev, 0);
>   		if (err < 0)
>   			goto errout;
>   	}
> _
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
