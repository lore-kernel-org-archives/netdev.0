From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 3/6] rtnetlink: add helper to dump ifalias
Date: Mon, 25 Sep 2017 20:34:28 -0700 (PDT)
Message-ID: <20170925.203428.970573407216523903.davem@davemloft.net>
References: <20170923192636.3932-1-fw@strlen.de>
        <20170923192636.3932-4-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40636 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933685AbdIZDe3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 23:34:29 -0400
In-Reply-To: <20170923192636.3932-4-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sat, 23 Sep 2017 21:26:33 +0200

> @@ -1332,6 +1332,14 @@ static int nla_put_iflink(struct sk_buff *skb, const struct net_device *dev)
>  	return nla_put_u32(skb, IFLA_LINK, ifindex);
>  }
>  
> +static noinline int nla_put_ifalias(struct sk_buff *skb, struct net_device *dev)

Please do use inline annoations in foo.c files unless there is a very strong
specific need.

Thank you.
