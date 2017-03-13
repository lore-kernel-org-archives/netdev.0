From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: optimize DMA in NUMA systems
Date: Sun, 12 Mar 2017 23:17:11 -0700 (PDT)
Message-ID: <20170312.231711.1974696961977380162.davem@davemloft.net>
References: <20170310010324.GA5986@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53348 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750783AbdCMGRN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:17:13 -0400
In-Reply-To: <20170310010324.GA5986@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 9 Mar 2017 17:03:24 -0800

> From: VSR Burru <veerasenareddy.burru@cavium.com>
> 
> Optimize DMA in NUMA systems by allocating memory from NUMA node that NIC
> is plugged in to; DMA will no longer cross NUMA nodes.  If NIC IRQs are
> pinned to a local CPU, that CPU's access to the DMA'd data is also
> optimized.
> 
> Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Applied, thanks.
