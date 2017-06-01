From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Fix Multi-Cos
Date: Thu, 01 Jun 2017 12:22:59 -0400 (EDT)
Message-ID: <20170601.122259.945935496179490442.davem@davemloft.net>
References: <20170601125756.25019-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56740 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751078AbdFAQXB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 12:23:01 -0400
In-Reply-To: <20170601125756.25019-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Thu, 1 Jun 2017 15:57:56 +0300

> Apparently multi-cos isn't working for bnx2x quite some time -
> driver implements ndo_select_queue() to allow queue-selection
> for FCoE, but the regular L2 flow would cause it to modulo the
> fallback's result by the number of queues.
> The fallback would return a queue matching the needed tc
> [via __skb_tx_hash()], but since the modulo is by the number of TSS
> queues where number of TCs is not accounted, transmission would always
> be done by a queue configured into using TC0.
> 
> Fixes: ada7c19e6d27 ("bnx2x: use XPS if possible for bnx2x_select_queue instead of pure hash")
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied and queued up for -stable.
