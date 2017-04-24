From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: bcmgenet: fix incorrect return value checks
Date: Mon, 24 Apr 2017 15:48:06 -0400 (EDT)
Message-ID: <20170424.154806.387657447648095027.davem@davemloft.net>
References: <1492941665-17155-1-git-send-email-bianpan201602@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bianpan2016@163.com
To: bianpan201602@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56774 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S972541AbdDXTsL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 15:48:11 -0400
In-Reply-To: <1492941665-17155-1-git-send-email-bianpan201602@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan201602@163.com>
Date: Sun, 23 Apr 2017 18:01:05 +0800

> From: Pan Bian <bianpan2016@163.com>
> 
> Function platform_get_irq() will return a negative value on errors.
> However, in function bcmgenet_probe(), 0 is considered as a flag of
> error. This patch fixes the bug by checking whether the return value of
> platform_get_irq() is less than 0.
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

I'm definitely not confident enough to apply this.

On some platform zero IRQs are invalid.

There are also lots of pieces of code that check the return value ">
0" as success.
