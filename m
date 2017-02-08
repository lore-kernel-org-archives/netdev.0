From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ping: fix a null pointer dereference
Date: Wed, 08 Feb 2017 13:58:52 -0500 (EST)
Message-ID: <20170208.135852.779430967423827569.davem@davemloft.net>
References: <1486501187-12869-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com, dvyukov@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57324 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751562AbdBHTf4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:35:56 -0500
In-Reply-To: <1486501187-12869-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  7 Feb 2017 12:59:46 -0800

> Andrey reported a kernel crash:
 ...
> This is because we miss a check for NULL pointer for skb_peek() when
> the queue is empty. Other places already have the same check.
> 
> Fixes: c319b4d76b9e ("net: ipv4: add IPPROTO_ICMP socket kind")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks Cong.
