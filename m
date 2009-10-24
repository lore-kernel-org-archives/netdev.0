From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rtnetlink: speedup rtnl_dump_ifinfo()
Date: Sat, 24 Oct 2009 06:13:29 -0700 (PDT)
Message-ID: <20091024.061329.94127938.davem@davemloft.net>
References: <4AE06D81.4050003@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@lhnet.ca
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58963
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753333AbZJXNNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 09:13:06 -0400
In-Reply-To: <4AE06D81.4050003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Oct 2009 16:34:41 +0200

> When handling large number of netdevice, rtnl_dump_ifinfo()
> is very slow because it has O(N^2) complexity.
> 
> Instead of scanning one single list, we can use the 256 sub lists
> of the dev_index hash table.
> 
> This considerably speedups "ip link" operations
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks!
