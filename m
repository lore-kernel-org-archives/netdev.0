From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5 net-next v2] ibmvnic: LPM bug fixes
Date: Thu, 15 Jun 2017 14:31:27 -0400 (EDT)
Message-ID: <20170615.143127.891558578047283901.davem@davemloft.net>
References: <1497502209-16248-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59354 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752828AbdFOSba (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 14:31:30 -0400
In-Reply-To: <1497502209-16248-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 14 Jun 2017 23:50:04 -0500

> This series of small patches is meant to resolve a number of
> bugs, mostly occurring during an ibmvnic driver reset when
> recovering from a logical partition migration (LPM).
> 
> The first patch ensures that RX buffer pools are properly
> activated following an adapter reset by setting the proper
> flag in the pool data structure.
> 
> The second patch uses netif_tx_disable to stop TX queues when
> closing the device during a reset.
> 
> Third, fixup a typo that resulted in partial sanitization of
> TX/RX descriptor queues following a device reset.
> 
> Fourth, remove an ambiguous conditional check that was resulting
> in a kernel panic as null RX/TX completion descriptors were being
> processed during napi polling while the device is closing.
> 
> Finally, fix a condition where the napi polling routine exits
> before it has completed its work budget without notifying the
> upper network layers. This omission could result in the
> napi_disable function sleeping indefinitely under certain conditions.
> 
> v2: Attempt to provide a proper cover letter

Series applied, thank you.
