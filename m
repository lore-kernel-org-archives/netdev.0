From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] ipmr: RCU protection for mfc_cache_array
Date: Sun, 03 Oct 2010 21:51:45 -0700 (PDT)
Message-ID: <20101003.215145.104063249.davem@davemloft.net>
References: <1285985708.2582.523.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39886
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751763Ab0JDEvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 00:51:25 -0400
In-Reply-To: <1285985708.2582.523.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 02 Oct 2010 04:15:08 +0200

> Use RCU & RTNL protection for mfc_cache_array[]
> 
> ipmr_cache_find() is called under rcu_read_lock();
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
