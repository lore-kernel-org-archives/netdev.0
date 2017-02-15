From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 5/7] net/sched: cls_matchall: Reflect HW
 offloading status
Date: Wed, 15 Feb 2017 13:15:56 -0500 (EST)
Message-ID: <20170215.131556.2072311430827899930.davem@davemloft.net>
References: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com>
        <1487148757-24809-6-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, john.r.fastabend@intel.com,
        jhs@mojatatu.com, roid@mellanox.com, jiri@mellanox.com,
        netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36920 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750806AbdBOSP7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 13:15:59 -0500
In-Reply-To: <1487148757-24809-6-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 15 Feb 2017 10:52:35 +0200

> @@ -194,6 +199,9 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
>  		}
>  	}
>  
> +	if (!(tc_in_hw(new->flags)))
> +		new->flags |= TCA_CLS_FLAGS_NOT_IN_HW;

Too many parenthesis, please make this:

	if (!tc_in_hw(new->flags))
		new->flags |= TCA_CLS_FLAGS_NOT_IN_HW;

Thanks.
