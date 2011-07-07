From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] af_packet: lock imbalance
Date: Thu, 07 Jul 2011 06:41:59 -0700 (PDT)
Message-ID: <20110707.064159.353179211742855614.davem@davemloft.net>
References: <1310045587.2127.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52774 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756249Ab1GGNmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 09:42:03 -0400
In-Reply-To: <1310045587.2127.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Jul 2011 15:33:07 +0200

> fanout_add() might return with fanout_mutex held.
> 
> Reduce indentation level while we are at it
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks for fixing this Eric.
