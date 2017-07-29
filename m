From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net v2] team: use a larger struct for mac address
Date: Sat, 29 Jul 2017 11:26:06 -0700 (PDT)
Message-ID: <20170729.112606.1858437006274122944.davem@davemloft.net>
References: <20170726222207.5922-2-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com, jiri@resnulli.us
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40126 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752947AbdG2S0H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 14:26:07 -0400
In-Reply-To: <20170726222207.5922-2-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 26 Jul 2017 15:22:07 -0700

> IPv6 tunnels use sizeof(struct in6_addr) as dev->addr_len,
> but in many places especially bonding, we use struct sockaddr
> to copy and set mac addr, this could lead to stack out-of-bounds
> access.
> 
> Fix it by using a larger address storage like bonding.
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
