From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: Fixing bad size of event queue buffer
Date: Thu, 31 Mar 2011 02:52:33 -0700 (PDT)
Message-ID: <20110331.025233.189713209.davem@davemloft.net>
References: <4D9449A9.9070600@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55120
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752884Ab1CaJxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 05:53:11 -0400
In-Reply-To: <4D9449A9.9070600@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 31 Mar 2011 11:30:17 +0200

> We should reduce the number of reserved completion queues from the total
> number of entries. Since the queue size is power of two, not reducing the
> reserved entries, caused a double queue size, which may lead to allocation
> failures in some cases.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
