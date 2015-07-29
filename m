From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: remove handling of tx_ring from
 prb_shutdown_retire_blk_timer()
Date: Wed, 29 Jul 2015 15:11:39 -0700 (PDT)
Message-ID: <20150729.151139.777528862235220131.davem@davemloft.net>
References: <1438086086-10014-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544AbbG2WLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 18:11:40 -0400
In-Reply-To: <1438086086-10014-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 28 Jul 2015 14:21:26 +0200

> Follow e8e85cc5eb57 ("packet: remove handling of tx_ring") and remove
> the tx_ring parameter from prb_shutdown_retire_blk_timer() as it is only
> called with tx_ring = 0.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
