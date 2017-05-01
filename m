From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xfrm: Indicate xfrm_state offload errors
Date: Mon, 01 May 2017 15:00:20 -0400 (EDT)
Message-ID: <20170501.150020.1978917857189385793.davem@davemloft.net>
References: <20170430135119.11159-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: ilant@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36058 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750759AbdEATA1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 15:00:27 -0400
In-Reply-To: <20170430135119.11159-1-ilant@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <ilant@mellanox.com>
Date: Sun, 30 Apr 2017 16:51:19 +0300

> From: Ilan Tayari <ilant@mellanox.com>
> 
> Current code silently ignores driver errors when configuring
> IPSec offload xfrm_state, and falls back to host-based crypto.
> 
> Fail the xfrm_state creation if the driver has an error, because
> the NIC offloading was explicitly requested by the user program.
> 
> This will communicate back to the user that there was an error.
> 
> Fixes: d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API")
> Signed-off-by: Ilan Tayari <ilant@mellanox.com>

Also applied.

Steffen, I apologize for taking these directly but I really wanted to
make sure these fixes made it into the pull request I plan to send to
Linus for the merge window soon.

Thanks.
