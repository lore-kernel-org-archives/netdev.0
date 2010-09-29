From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: add a recursion limit in xmit path
Date: Wed, 29 Sep 2010 13:23:23 -0700 (PDT)
Message-ID: <20100929.132323.28800834.davem@davemloft.net>
References: <AANLkTinCz_0jHsMYW9_Wko78i9U20qefFbTYCQQQ-pz5@mail.gmail.com>
	<1285785794.2813.292.camel@edumazet-laptop>
	<1285787072.2813.333.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51294
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754398Ab0I2UXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 16:23:04 -0400
In-Reply-To: <1285787072.2813.333.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Sep 2010 21:04:32 +0200

> [PATCH net-next-2.6] net: add a recursion limit in xmit path
> 
> As tunnel devices are going to be lockless, we need to make sure a
> misconfigured machine wont enter an infinite loop.
> 
> Add a percpu variable, and limit to three the number of stacked xmits.
> 
> Reported-by: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
