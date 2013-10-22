From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESENT net-next] net: remove function sk_reset_txq()
Date: Tue, 22 Oct 2013 14:00:33 -0400 (EDT)
Message-ID: <20131022.140033.505525780006392986.davem@davemloft.net>
References: <20131022082338.GA19349@will>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gamerh2o@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584Ab3JVSAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 14:00:34 -0400
In-Reply-To: <20131022082338.GA19349@will>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ZHAO Gang <gamerh2o@gmail.com>
Date: Tue, 22 Oct 2013 16:23:38 +0800

> What sk_reset_txq() does is just calls function sk_tx_queue_reset(),
> and sk_reset_txq() is used only in sock.h, by dst_negative_advice().
> Let dst_negative_advice() calls sk_tx_queue_reset() directly so we
> can remove unneeded sk_reset_txq().
> 
> Signed-off-by: ZHAO Gang <gamerh2o@gmail.com>

Applied, thanks.
