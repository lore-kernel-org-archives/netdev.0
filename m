From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 resubmit] skbuff: optimize the pull_pages
 code in __pskb_pull_tail()
Date: Mon, 17 Jul 2017 08:57:09 -0700 (PDT)
Message-ID: <20170717.085709.2142300767506652828.davem@davemloft.net>
References: <1500283502-36546-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: xiaolou4617@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53066 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751293AbdGQP5K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 11:57:10 -0400
In-Reply-To: <1500283502-36546-1-git-send-email-xiaolou4617@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lin Zhang <xiaolou4617@gmail.com>
Date: Mon, 17 Jul 2017 17:25:02 +0800

> In the pull_pages code block, if the first frag size > eat,
> we can end the loop in advance to avoid extra copy.
> 
> Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>

Applied, thanks.
