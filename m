From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix inaccurate count of
 napi-processed rx packets reported to Octeon
Date: Fri, 26 May 2017 14:42:41 -0400 (EDT)
Message-ID: <20170526.144241.1366515927726150516.davem@davemloft.net>
References: <20170525175429.GA1476@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        prasad.kanneganti@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43412 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948613AbdEZSmn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 14:42:43 -0400
In-Reply-To: <20170525175429.GA1476@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 25 May 2017 10:54:29 -0700

> From: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> 
> lio_enable_irq (called by napi poll) is reporting to Octeon an inaccurate
> count of processed rx packets causing Octeon to eventually stop forwarding
> packets to the host.  Fix it by using this formula for an accurate count:
> 
>     processed rx packets = droq->pkt_count - droq->pkts_pending
> 
> Also increase SOFT_COMMAND_BUFFER_SIZE to match what the firmware expects.
> 
> Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
