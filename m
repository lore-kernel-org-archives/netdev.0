From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: fix attempt to translate invalid filter ID
Date: Thu, 29 Jun 2017 16:02:45 -0400 (EDT)
Message-ID: <20170629.160245.963659993885114524.davem@davemloft.net>
References: <ac506723-66ef-0945-ff1e-c0132f0c71c0@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45508 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752770AbdF2UCr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 16:02:47 -0400
In-Reply-To: <ac506723-66ef-0945-ff1e-c0132f0c71c0@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Thu, 29 Jun 2017 16:50:06 +0100

> When filter insertion fails with no rollback, we were trying to convert
>  EFX_EF10_FILTER_ID_INVALID to an id to store in 'ids' (which is either
>  vlan->uc or vlan->mc).  This would WARN_ON_ONCE and then record a bogus
>  filter ID of 0x1fff, neither of which is a good thing.
> 
> Fixes: 0ccb998bf46d ("sfc: fix filter_id misinterpretation in edge case")
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied, thanks.
