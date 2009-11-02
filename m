From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] icmp: icmp_send() can avoid a dev_put()
Date: Sun, 01 Nov 2009 23:57:03 -0800 (PST)
Message-ID: <20091101.235703.105593995.davem@davemloft.net>
References: <4AEE6E97.5070809@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40362
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754102AbZKBH4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 02:56:38 -0500
In-Reply-To: <4AEE6E97.5070809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Nov 2009 06:31:03 +0100

> We can avoid touching device refcount in icmp_send(),
> using dev_get_by_index_rcu()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
