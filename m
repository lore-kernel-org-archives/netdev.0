From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: use meaningful names for IRQs
Date: Thu, 16 Mar 2017 20:20:43 -0700 (PDT)
Message-ID: <20170316.202043.1747040871993595115.davem@davemloft.net>
References: <20170313195804.GA1796@felix2.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53862 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752029AbdCQD3s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 23:29:48 -0400
In-Reply-To: <20170313195804.GA1796@felix2.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Mon, 13 Mar 2017 12:58:04 -0700

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> All IRQs owned by the PF and VF drivers share the same nondescript name
> "octeon"; this makes it difficult to setup interrupt affinity.
> 
> Change the IRQ names to reflect their specific purpose:
> 
>     LiquidIO<id>-<func>-<type>-<queue pair num>
> 
> Examples:
>     LiquidIO0-pf0-rxtx-3
>     LiquidIO1-vf1-rxtx-0
>     LiquidIO0-pf0-aux
> 
> We cannot use netdev->name for naming the IRQs because:
> 
>     1.  Early during init, the PF and VF drivers require interrupts to
>         send/receive control data from the NIC firmware; so the PF and VF
>         must request IRQs long before the netdev struct is registered.
> 
>     2.  The IRQ name can only be specified at the time it is requested.
>         It cannot be changed after that.
> 
> Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Applied, thank you.
