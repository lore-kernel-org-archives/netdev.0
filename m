From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/3] net: add rtnl_dereference()
Date: Wed, 15 Sep 2010 19:30:57 -0700 (PDT)
Message-ID: <20100915.193057.71567026.davem@davemloft.net>
References: <1284584835.2462.69.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38492
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751620Ab0IPCak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 22:30:40 -0400
In-Reply-To: <1284584835.2462.69.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Sep 2010 23:07:15 +0200

> We sometime want to dereference an rcu protected pointer while
> holding RTNL. Use a macro to hide all lockdep details.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
