From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] bnx2x: Use the correct divisor value for PHC
 clock readings.
Date: Sun, 23 Oct 2016 17:35:36 -0400 (EDT)
Message-ID: <20161023.173536.1788951887292966152.davem@davemloft.net>
References: <1477030157-30700-1-git-send-email-Sony.Chacko@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@cavium.com,
        Yuval.Mintz@cavium.com, sudarsana.kalluru@cavium.com
To: Sony.Chacko@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754130AbcJWVfh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 17:35:37 -0400
In-Reply-To: <1477030157-30700-1-git-send-email-Sony.Chacko@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Sony.Chacko@cavium.com>
Date: Fri, 21 Oct 2016 02:09:17 -0400

> From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
> 
> Time Sync (PTP) implementation uses the divisor/shift value for converting
> the clock ticks to nanoseconds. Driver currently defines shift value as 1,
> this results in the nanoseconds value to be calculated as half the actual
> value. Hence the user application fails to synchronize the device clock
> value with the PTP master device clock. Need to use the 'shift' value of 0.
> 
> Signed-off-by: Sony.Chacko <Sony.Chacko@cavium.com>
> Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied, thanks.
