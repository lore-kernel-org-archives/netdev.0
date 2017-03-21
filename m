From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: Track per TX/RX rings
 statistics
Date: Tue, 21 Mar 2017 15:30:34 -0700 (PDT)
Message-ID: <20170321.153034.1285790422123768475.davem@davemloft.net>
References: <20170316172708.32008-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, pgynther@google.com,
        jaedon.shin@gmail.com, opendmb@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57764 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933247AbdCUWal (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 18:30:41 -0400
In-Reply-To: <20170316172708.32008-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 16 Mar 2017 10:27:08 -0700

> __bcmgenet_tx_reclaim() is currently summing TX bytes/packets in a way
> that is not SMP friendly, mutliples CPUs could run
> __bcmgenet_tx_reclaim() independently and still update stats->tx_bytes
> and stats->tx_packets, cloberring the other CPUs statistics.
> 
> Fix this by tracking per RX and TX rings the number of bytes, packets,
> dropped and errors statistics, and provide a bcmgenet_get_stats()
> function which aggregates everything and returns a consistent output.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
