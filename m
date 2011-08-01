From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: use RCU in inet6_csk_xmit()
Date: Mon, 01 Aug 2011 01:55:50 -0700 (PDT)
Message-ID: <20110801.015550.1280455486365024586.davem@davemloft.net>
References: <1311860627.2346.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab1HAIzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 04:55:52 -0400
In-Reply-To: <1311860627.2346.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 Jul 2011 15:43:47 +0200

> Use RCU to avoid changing dst_entry refcount in fast path.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Queued up for net-next
