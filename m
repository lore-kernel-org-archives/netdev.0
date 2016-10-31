From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qede: Fix statistics' strings for Tx/Rx queues
Date: Mon, 31 Oct 2016 15:34:00 -0400 (EDT)
Message-ID: <20161031.153400.1962899191006711223.davem@davemloft.net>
References: <1477815942-9486-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56624 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945645AbcJaTeB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:34:01 -0400
In-Reply-To: <1477815942-9486-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Sun, 30 Oct 2016 10:25:42 +0200

> When an interface is configured to use Tx/Rx-only queues,
> the length of the statistics would be shortened to accomodate only the
> statistics required per-each queue, and the values would be provided
> accordingly.
> However, the strings provided would still contain both Tx and Rx strings
> for each one of the queues [regardless of its configuration], which might
> lead to out-of-bound access when filling the buffers as well as incorrect
> statistics presented.
> 
> Fixes: 9a4d7e86acf3 ("qede: Add support for Tx/Rx-only queues.")
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied, thanks.
