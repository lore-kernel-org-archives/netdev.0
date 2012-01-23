From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: fix a possible use after free
Date: Mon, 23 Jan 2012 13:56:40 -0500 (EST)
Message-ID: <20120123.135640.2248340776790073045.davem@davemloft.net>
References: <1327333139.2525.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729Ab2AWS4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 13:56:45 -0500
In-Reply-To: <1327333139.2525.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Jan 2012 16:38:59 +0100

> Commit bc416d9768 (macvlan: handle fragmented multicast frames) added a
> possible use after free in macvlan_handle_frame(), since
> ip_check_defrag() uses pskb_may_pull() : skb header can be reallocated.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Ben Greear <greearb@candelatech.com>

Applied, thanks.
