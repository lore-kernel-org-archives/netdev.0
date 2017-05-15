From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/6] net/mlx5e: Use a spinlock to synchronize statistics
Date: Mon, 15 May 2017 14:39:48 -0400 (EDT)
Message-ID: <20170515.143948.1759849420537263846.davem@davemloft.net>
References: <20170512115650.11635-2-saeedm@mellanox.com>
        <20170512.121354.1583292892374462482.davem@davemloft.net>
        <CALzJLG-CbN5ipg3_CsN9_1RWtY_q_UaQGMu3KwDpgoYk53xkOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, galp@mellanox.com,
        kernel-team@fb.com
To: saeedm@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932948AbdEOSju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 14:39:50 -0400
In-Reply-To: <CALzJLG-CbN5ipg3_CsN9_1RWtY_q_UaQGMu3KwDpgoYk53xkOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Date: Sun, 14 May 2017 11:52:13 +0300

> I agree, it is really ridiculous that we allocate/free a couple of
> buffers on each update_stats operations, regardless of this patch.
> Is it ok if we use a temp buffer under netdev_priv for such usages or
> even use kmemcache ?

If you can safely use a pre-allocated tmp buffer, yes that would be
preferred.
