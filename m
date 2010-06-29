From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/4] net: u64_stats_fetch_begin_bh() and
 u64_stats_fetch_retry_bh()
Date: Mon, 28 Jun 2010 23:37:38 -0700 (PDT)
Message-ID: <20100628.233738.212687706.davem@davemloft.net>
References: <1277376846.2816.283.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37636
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752363Ab0F2GhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:37:25 -0400
In-Reply-To: <1277376846.2816.283.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Jun 2010 12:54:06 +0200

> - Must disable preemption in case of 32bit UP in u64_stats_fetch_begin()
> and u64_stats_fetch_retry()
> 
> - Add new u64_stats_fetch_begin_bh() and u64_stats_fetch_retry_bh() for
> network usage, disabling BH on 32bit UP only.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
