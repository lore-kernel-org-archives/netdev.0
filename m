From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: add code comment for clarification
Date: Mon, 08 May 2017 11:36:37 -0400 (EDT)
Message-ID: <20170508.113637.783558334411383400.davem@davemloft.net>
References: <20170504142432.Horde.g9y26Ryxbtg1EIl_cnsdbbw@gator4166.hostgator.com>
        <20170504194415.GA29391@embeddedgus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, joe@perches.com
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170504194415.GA29391@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Thu, 4 May 2017 14:44:16 -0500

> @@ -389,6 +389,12 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
>  				  nlmsg_flags, unlh, net_admin);
>  }
>  
> +/*
> + * Ignore the position of the arguments req->id.idiag_dport and
> + * req->id.idiag_sport in both calls to inet_lookup() and inet6_lookup()
> + * functions, once this is a locked in behavior exposed to user space.
> + * Changing this will break things for people.
> + */

This is implicit for every interface exposed to userspace.

Therefore, saying it here and there in various comments provides
questionable value.

And in fact I think these arguments are probably in the correct order.

I'm definitely not applying a patch like this, sorry.
