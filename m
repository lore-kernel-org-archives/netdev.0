From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: replace skb_tx_hash with fallback
Date: Thu, 12 Jan 2017 16:51:12 -0500 (EST)
Message-ID: <20170112.165112.10208126265116548.davem@davemloft.net>
References: <20170112184606.GA5503@felix.cavium.com>
        <1484248218.3321.1.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felix.manlunas@cavium.com, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58484 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750797AbdALVvO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 16:51:14 -0500
In-Reply-To: <1484248218.3321.1.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Jan 2017 11:10:18 -0800

> Why are you keeping these functions then ?
> 
> Remove them completely, and remove .ndo_select_queue from your ops.
> 
> Core networking stack will fallback automatically.

Agreed, if all the queue selection function is doing is invoking the
fallback, get rid of it.
