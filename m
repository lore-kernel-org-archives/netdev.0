From: David Miller <davem@davemloft.net>
Subject: Re: [PPATCH net-next-2.6] ipv4: inetdev_by_index() switch to RCU
Date: Sun, 01 Nov 2009 23:56:58 -0800 (PST)
Message-ID: <20091101.235658.264135604.davem@davemloft.net>
References: <4AEE6CB8.1000106@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40359
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754027AbZKBH4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 02:56:33 -0500
In-Reply-To: <4AEE6CB8.1000106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Nov 2009 06:23:04 +0100

> Use dev_get_by_index_rcu() instead of __dev_get_by_index() and
> dev_base_lock rwlock
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Man, you've been busy.... :-)

Applied, thanks!
