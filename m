From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 6/7] net/sched: cls_u32: Reflect HW offload
 status
Date: Wed, 15 Feb 2017 13:16:21 -0500 (EST)
Message-ID: <20170215.131621.1024613955864556616.davem@davemloft.net>
References: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com>
        <1487148757-24809-7-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, john.r.fastabend@intel.com,
        jhs@mojatatu.com, roid@mellanox.com, jiri@mellanox.com,
        netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36932 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751802AbdBOSQW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 13:16:22 -0500
In-Reply-To: <1487148757-24809-7-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 15 Feb 2017 10:52:36 +0200

> @@ -895,6 +899,9 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
>  			return err;
>  		}
>  
> +		if (!(tc_in_hw(new->flags)))

Less parenthesis, please.

> @@ -1014,6 +1021,9 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
>  		if (err)
>  			goto errhw;
>  
> +		if (!(tc_in_hw(n->flags)))

Likewise.
