From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: systemport: Only inspect valid switch
 port & queues
Date: Thu, 02 Nov 2017 16:49:54 +0900 (KST)
Message-ID: <20171102.164954.1869306758273167836.davem@davemloft.net>
References: <20171101182947.31886-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44824 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdKBHt6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 03:49:58 -0400
In-Reply-To: <20171101182947.31886-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed,  1 Nov 2017 11:29:47 -0700

> Hesoteric board configurations where port 0 is not available would still
> make SYSTEMPORT inspect the switch port 0, queue 0, which, not being
> enabled, would cause transmit timeouts over time. Just ignore those
> unconfigured rings instead.
> 
> Fixes: 84ff33eeb23d ("net: systemport: Establish DSA network device queue mapping")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
