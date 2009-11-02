From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ip6tnl: less dev_put() calls
Date: Mon, 02 Nov 2009 03:43:02 -0800 (PST)
Message-ID: <20091102.034302.134298866.davem@davemloft.net>
References: <4AEEB2B1.9070302@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39619
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754614AbZKBLmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 06:42:38 -0500
In-Reply-To: <4AEEB2B1.9070302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Nov 2009 11:21:37 +0100

> Using dev_get_by_index_rcu() in ip6_tnl_rcv_ctl() & ip6_tnl_xmit_ctl()
> avoids touching device refcount.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
