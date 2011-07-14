From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/1] af-packet: fix - avoid reading stale
 data
Date: Thu, 14 Jul 2011 08:36:42 -0700 (PDT)
Message-ID: <20110714.083642.1356154588833217908.davem@davemloft.net>
References: <1310525269-1288-1-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lokechetan@gmail.com,
	eric.dumazet@gmail.com
To: loke.chetan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754639Ab1GNPgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 11:36:46 -0400
In-Reply-To: <1310525269-1288-1-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chetan Loke <loke.chetan@gmail.com>
Date: Tue, 12 Jul 2011 22:47:49 -0400

> Currently we flush tp_status and then flush the remainder of the header+payload.
> tp_status should be flushed in the end to avoid stale data being read by user-space.
> 
> Incorrectly re-ordered barriers in v1.
> 
> Signed-off-by: Chetan Loke <loke.chetan@gmail.com>

Applied, thanks.
