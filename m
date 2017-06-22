From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: Fix MCDI command size for filter operations
Date: Thu, 22 Jun 2017 13:42:09 -0400 (EDT)
Message-ID: <20170622.134209.1369507682216811264.davem@davemloft.net>
References: <89eade1b-405f-07f6-3f0b-ffeeb74ea618@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: mhabets@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39140 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751156AbdFVRmK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 13:42:10 -0400
In-Reply-To: <89eade1b-405f-07f6-3f0b-ffeeb74ea618@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Habets <mhabets@solarflare.com>
Date: Thu, 22 Jun 2017 10:50:41 +0100

> The 8000 series adapters uses catch-all filters for encapsulated traffic
> to support filtering VXLAN, NVGRE and GENEVE traffic.
> This new filter functionality requires a longer MCDI command.
> This patch increases the size of buffers on stack that were missed, which
> fixes a kernel panic from the stack protector.
> 
> Fixes: 9b41080125176 ("sfc: insert catch-all filters for encapsulated traffic")
> Signed-off-by: Martin Habets <mhabets@solarflare.com>
> Acked-by: Edward Cree <ecree@solarflare.com>
> Acked-by: Bert Kenward bkenward@solarflare.com

Applied and queued up for -stable.
