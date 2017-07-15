From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ioc3-eth: store pointer to net_device for priviate area
Date: Sat, 15 Jul 2017 14:30:20 -0700 (PDT)
Message-ID: <20170715.143020.159307310638213706.davem@davemloft.net>
References: <20170710120032.11173-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
        netdev@vger.kernel.org
To: Jason@zx2c4.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54442 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdGOVaV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Jul 2017 17:30:21 -0400
In-Reply-To: <20170710120032.11173-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon, 10 Jul 2017 14:00:32 +0200

> Computing the alignment manually for going from priv to pub is probably
> not such a good idea, and in general the assumption that going from priv
> to pub is possible trivially could change, so rather than relying on
> that, we change things to just store a pointer to pub. This was sugested
> by DaveM in [1].
> 
> [1] http://www.spinics.net/lists/netdev/msg443992.html
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Applied.
