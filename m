From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] net: clean up some sparse endianness warnings in
 ipv6.h
Date: Wed, 16 Jul 2014 23:31:51 -0700 (PDT)
Message-ID: <20140716.233151.1229307096154836730.davem@davemloft.net>
References: <1405340746-10678-1-git-send-email-jlayton@primarydata.com>
	<1405508146-13004-1-git-send-email-jlayton@primarydata.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org,
	kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: jlayton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405508146-13004-1-git-send-email-jlayton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jeff Layton <jlayton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Date: Wed, 16 Jul 2014 06:55:46 -0400

> sparse is throwing warnings when building sunrpc modules due to some
> endianness shenanigans in ipv6.h. Specifically:
> 
>   CHECK   net/sunrpc/addr.c
> include/net/ipv6.h:573:17: warning: restricted __be64 degrades to integer
> include/net/ipv6.h:577:34: warning: restricted __be32 degrades to integer
> include/net/ipv6.h:573:17: warning: restricted __be64 degrades to integer
> include/net/ipv6.h:577:34: warning: restricted __be32 degrades to integer
> 
> Sprinkle some endianness fixups to silence them. These should all get
> fixed up at compile time, so I don't think this will add any extra work
> to be done at runtime.
> 
> Signed-off-by: Jeff Layton <jlayton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>

Applied, thank you.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
