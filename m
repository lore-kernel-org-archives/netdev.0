From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Tue, 27 Sep 2016 01:56:06 -0400 (EDT)
Message-ID: <20160927.015606.437705429903770747.davem@davemloft.net>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
        <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: shmulik.ladkani@ravellosystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42870 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbcI0F4N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 01:56:13 -0400
In-Reply-To: <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Date: Thu, 22 Sep 2016 16:21:52 +0300

> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> 
> Up until now, 'action mirred' supported only egress actions (either
> TCA_EGRESS_REDIR or TCA_EGRESS_MIRROR).
> 
> This patch implements the corresponding ingress actions
> TCA_INGRESS_REDIR and TCA_INGRESS_MIRROR.
> 
> This allows attaching filters whose target is to hand matching skbs into
> the rx processing of a specified device.
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  Was wondering, whether netif_receive_skb or dev_forward_skb should be
>  used for the rx bouncing. Used netif_receive_skb as in ifb device.

The discussion on this patch has ventured off into what to do about
recursion.

But it unclear to me where this specific patch, and this series,
stands right now.  Someone please clear this up for me.

Thanks.
