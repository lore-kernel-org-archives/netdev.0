From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] datapath: Avoid using stack larger than
 1024.
Date: Sat, 01 Jul 2017 09:10:55 -0700 (PDT)
Message-ID: <20170701.091055.4333181967829415.davem@davemloft.net>
References: <1498782464-47146-1-git-send-email-nic@opencloud.tech>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org, gvrose8192@gmail.com
To: xiangxia.m.yue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751389AbdGAQK6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 12:10:58 -0400
In-Reply-To: <1498782464-47146-1-git-send-email-nic@opencloud.tech>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: nickcooper-zhangtonghao <xiangxia.m.yue@gmail.com>
Date: Thu, 29 Jun 2017 17:27:44 -0700

> From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
> 
> When compiling OvS-master on 4.4.0-81 kernel,
> there is a warning:
> 
>     CC [M]  /root/ovs/datapath/linux/datapath.o
>     /root/ovs/datapath/linux/datapath.c: In function
>     'ovs_flow_cmd_set':
>     /root/ovs/datapath/linux/datapath.c:1221:1: warning:
>     the frame size of 1040 bytes is larger than 1024 bytes
>     [-Wframe-larger-than=]
> 
> This patch factors out match-init and action-copy to avoid
> "Wframe-larger-than=1024" warning. Because mask is only
> used to get actions, we new a function to save some
> stack space.
> 
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
> Acked-by: Pravin B Shelar <pshelar@ovn.org>

Applied.
