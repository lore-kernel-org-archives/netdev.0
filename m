From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 7/7] net/sched: cls_bpf: Reflect HW offload
 status
Date: Wed, 15 Feb 2017 13:16:39 -0500 (EST)
Message-ID: <20170215.131639.2135113997581761666.davem@davemloft.net>
References: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com>
        <1487148757-24809-8-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, john.r.fastabend@intel.com,
        jhs@mojatatu.com, roid@mellanox.com, jiri@mellanox.com,
        netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36950 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751652AbdBOSQl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 13:16:41 -0500
In-Reply-To: <1487148757-24809-8-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 15 Feb 2017 10:52:37 +0200

> @@ -511,6 +517,9 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
>  		return ret;
>  	}
>  
> +	if (!(tc_in_hw(prog->gen_flags)))

Again, less parenthesis.

Thanks.
