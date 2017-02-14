From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sfc: prevent bogus interrupt-mode
 fallbacks
Date: Tue, 14 Feb 2017 12:45:24 -0500 (EST)
Message-ID: <20170214.124524.830689543639993890.davem@davemloft.net>
References: <2af4ea1f-cdf7-48b2-1712-e25590919f15@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38150 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932290AbdBNRp0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 12:45:26 -0500
In-Reply-To: <2af4ea1f-cdf7-48b2-1712-e25590919f15@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Mon, 13 Feb 2017 14:54:56 +0000

> EF10 VFs only support MSI-X interrupts, not MSI or legacy.  This series
>  stops the probe logic from trying to fallback to those if MSI-X interrupt
>  probe fails.  It also prevents selecting them with the interrupt_mode
>  module parameter.
> This avoids producing messages like "failed to hook legacy IRQ 0" and "IRQ
>  handler type mismatch for IRQ 0", and ensures that the relevant error
>  (from the attempt to enable MSI-X) is reported to the caller.

Series applied, thanks Edward.
