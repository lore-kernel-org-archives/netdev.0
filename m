From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vrf: correct FRA_L3MDEV encode type
Date: Thu, 02 Nov 2017 16:22:44 +0900 (KST)
Message-ID: <20171102.162244.2062312593995148834.davem@davemloft.net>
References: <20171101145809.2362-1-0xeffeff@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: 0xeffeff@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44374 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751841AbdKBHWs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 03:22:48 -0400
In-Reply-To: <20171101145809.2362-1-0xeffeff@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Barnhill <0xeffeff@gmail.com>
Date: Wed,  1 Nov 2017 14:58:09 +0000

> FRA_L3MDEV is defined as U8, but is being added as a U32 attribute. On
> big endian architecture, this results in the l3mdev entry not being
> added to the FIB rules.
> 
> Fixes: 1aa6c4f6b8cd8 ("net: vrf: Add l3mdev rules on first device create")
> Signed-off-by: Jeff Barnhill <0xeffeff@gmail.com>

Applied and queued up for -stable, thank you.

I wish we could trap things like this using the policy,
enforcing an exact size access for attributes such as
these.

Thanks again.
