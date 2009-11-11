From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: speedup inet6_dump_ifinfo()
Date: Tue, 10 Nov 2009 22:34:51 -0800 (PST)
Message-ID: <20091110.223451.211569935.davem@davemloft.net>
References: <4AF89390.4000902@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59215
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753136AbZKKGeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:34:25 -0500
In-Reply-To: <4AF89390.4000902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 Nov 2009 23:11:28 +0100

> When handling large number of netdevice, inet6_dump_ifinfo()
> is very slow because it has O(N^2) complexity.
> 
> Instead of scanning one single list, we can use the 256 sub lists
> of the dev_index hash table, and RCU lookups.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
