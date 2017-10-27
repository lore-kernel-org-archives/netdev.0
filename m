From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] liquidio: xmit_more support
Date: Sat, 28 Oct 2017 00:35:46 +0900 (KST)
Message-ID: <20171028.003546.1014898137892267978.davem@davemloft.net>
References: <20171026231820.GA18787@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51520 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbdJ0Pfw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 11:35:52 -0400
In-Reply-To: <20171026231820.GA18787@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 26 Oct 2017 16:18:20 -0700

> From: Intiyaz Basha <intiyaz.basha@cavium.com>
> 
> Defer ringing the Tx doorbell if skb->xmit_more is set unless the Tx queue
> is full or stopped.  To keep latency low, use a deferral limit of 8
> packets.  We chose 8 because Octeon can fetch at most 8 packets in a single
> PCI read, and our tests show that 8 results in low latency.
> 
> Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> ---
> Patch Change Log:
>   V1 -> V2:
>     Add a Tx doorbell ring deferral limit as suggested by David Miller

Applied, thank you.
