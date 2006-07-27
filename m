From: David Miller <davem@davemloft.net>
Subject: Re: Netchannel: default, find, add to socket
Date: Wed, 26 Jul 2006 18:17:16 -0700 (PDT)
Message-ID: <20060726.181716.122314025.davem@davemloft.net>
References: <200607271050.00520.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15280
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750861AbWG0BRV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 21:17:21 -0400
To: kelly@au1.ibm.com
In-Reply-To: <200607271050.00520.kelly@au.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kelly Daly <kelly@au1.ibm.com>
Date: Thu, 27 Jul 2006 10:50:00 +1000

> Implement finding of correct netchannel for buffer, default netchannel and attach a netchannel to a socket
> 
> Signed-off-by:  Kelly Daly <kelly@au.ibm.com>

Patch is still corrupted.  My tolerance on this matter is growing
extremely thin.   Send these patches to yourself and try to apply
them, it will save me a lot of time.

> @@ -65,6 +71,10 @@ static inline struct netchannel_buftrail
>  	return __netchannel_dequeue(np);
>  }
>  
> +extern struct netchannel *find_netchannel(const struct netchannel_buftrailer *bp);
> +extern int sock_add_netchannel(struct sock *sk);
>  extern struct sk_buff *skb_netchan_graft(struct netchannel_buftrailer *, gfp_t);
>  
>  #endif /* _LINUX_NETCHANNEL_H */
> diff -urp davem/include/net/inet_hashtables.h kelly_new/include/net/inet_hashtables.h

This patch hunk states there are 10 lines in the new section of
the file, yet the hunk is truncated at 8 lines.
