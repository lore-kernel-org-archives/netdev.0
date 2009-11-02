From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: RCU locking for simple ioctl()
Date: Sun, 01 Nov 2009 23:57:08 -0800 (PST)
Message-ID: <20091101.235708.173394317.davem@davemloft.net>
References: <4AEE7131.601@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40365
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754159AbZKBH4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 02:56:44 -0500
In-Reply-To: <4AEE7131.601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Nov 2009 06:42:09 +0100

> All ioctls() implemented by dev_ifsioc_locked() :
> SIOCGIFFLAGS, SIOCGIFMETRIC, SIOCGIFMTU, SIOCGIFHWADDR,
> SIOCGIFSLAVE, SIOCGIFMAP, SIOCGIFINDEX & SIOCGIFTXQLEN
> can use RCU lock instead of dev_base_lock rwlock
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
