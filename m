From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: fix a leak of kernel memory
Date: Wed, 18 Aug 2010 23:40:24 -0700 (PDT)
Message-ID: <20100818.234024.58437901.davem@davemloft.net>
References: <1281965100.2524.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52053
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751327Ab0HSGkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 02:40:05 -0400
In-Reply-To: <1281965100.2524.52.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Aug 2010 15:25:00 +0200

> struct rds_rdma_notify contains a 32 bits hole on 64bit arches,
> make sure it is zeroed before copying it to user.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks a lot Eric.
