From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/4] act_mirred: Ingress actions support
Date: Fri, 14 Oct 2016 10:23:28 -0400 (EDT)
Message-ID: <20161014.102328.1338324981265661044.davem@davemloft.net>
References: <1476338804-25440-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, edumazet@google.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47562 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752585AbcJNOXa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 10:23:30 -0400
In-Reply-To: <1476338804-25440-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Thu, 13 Oct 2016 09:06:40 +0300

> This patch series implements action mirred 'ingress' actions
> TCA_INGRESS_REDIR and TCA_INGRESS_MIRROR.
> 
> This allows attaching filters whose target is to hand matching skbs into
> the rx processing of a specified device.
> 
> v4:
>   in 4/4, check ret code of netif_receive_skb, as suggested by Cong Wang
> v3:
>   in 4/4, addressed non coherency due to reading m->tcfm_eaction multiple
>   times, as spotted by Eric Dumazet
> v2:
>   in 1/4, declare tcfm_mac_header_xmit as bool instead of int

Series applied, thanks.
