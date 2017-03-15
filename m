From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tcp: remove per-destination timestamp
 cache
Date: Wed, 15 Mar 2017 15:40:44 -0700 (PDT)
Message-ID: <20170315.154044.170788541865531834.davem@davemloft.net>
References: <20170315203046.158791-1-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com, edumazet@google.com,
        ncardwell@google.com, ycheng@google.com, lvml@5t9.de, fw@strlen.de
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55436 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdCOWkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 18:40:45 -0400
In-Reply-To: <20170315203046.158791-1-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Wed, 15 Mar 2017 16:30:45 -0400

> Note that this cache was already broken for caching timestamps of
> multiple machines behind a NAT sharing the same address.

That's the documented, well established, limitation of time-wait
recycling.

People who enable it, need to consider this issue.

This limitation of the feature does not give us a reason to break the
feature even further as a matter of convenience, or to remove it
altogether for the same reason.

Please, instead, fix the bug that was introduced.

Thank you.
