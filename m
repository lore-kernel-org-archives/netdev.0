From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gro: use min_t() in skb_gro_reset_offset()
Date: Wed, 11 Jan 2017 08:16:34 -0500 (EST)
Message-ID: <20170111.081634.2168417008156230015.davem@davemloft.net>
References: <1484079841.21472.35.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170110.212911.71346127320993214.davem@davemloft.net>
        <1484106763.21472.49.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
        slavash@mellanox.com, willemb@google.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48194 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966471AbdAKNQs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 08:16:48 -0500
In-Reply-To: <1484106763.21472.49.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Jan 2017 19:52:43 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> On 32bit arches, (skb->end - skb->data) is not 'unsigned int',
> so we shall use min_t() instead of min() to avoid a compiler error.
> 
> Fixes: 1272ce87fa01 ("gro: Enter slow-path if there is no tailroom")
> Reported-by: kernel test robot <fengguang.wu@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
