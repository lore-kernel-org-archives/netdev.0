From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] filter: Add SKF_AD_QUEUE instruction
Date: Tue, 20 Oct 2009 01:08:31 -0700 (PDT)
Message-ID: <20091020.010831.176599629.davem@davemloft.net>
References: <4AD8A916.3060807@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59694
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751076AbZJTIIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 04:08:09 -0400
In-Reply-To: <4AD8A916.3060807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Oct 2009 19:10:46 +0200

> It can help being able to filter packets on their queue_mapping.
> 
> If filter performance is not good, we could add a "numqueue" field
> in struct packet_type, so that netif_nit_deliver() and other functions
> can directly ignore packets with not expected queue number.
> 
> Lets experiment this simple filter extension first.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, I had to adjust the SKF_AD_* number due to a conflict
with Jamal's SKF_AD_MARK patch which is also applied to net-next-2.6
