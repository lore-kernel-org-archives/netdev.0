From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: ensure ep is not destroyed before doing the
 dump
Date: Mon, 19 Jun 2017 15:14:16 -0400 (EDT)
Message-ID: <20170619.151416.320922975636462627.davem@davemloft.net>
References: <6861fd3fc029ccba569fabccf7e05f6a52f28415.1497687027.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37608 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752188AbdFSTOS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 15:14:18 -0400
In-Reply-To: <6861fd3fc029ccba569fabccf7e05f6a52f28415.1497687027.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 17 Jun 2017 16:10:27 +0800

> Now before dumping a sock in sctp_diag, it only holds the sock while
> the ep may be already destroyed. It can cause a use-after-free panic
> when accessing ep->asocs.
> 
> This patch is to set sctp_sk(sk)->ep NULL in sctp_endpoint_destroy,
> and check if this ep is already destroyed before dumping this ep.
> 
> Suggested-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.
