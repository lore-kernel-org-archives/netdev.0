From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] ipmr: __pim_rcv() is called under
 rcu_read_lock
Date: Sun, 03 Oct 2010 21:51:35 -0700 (PDT)
Message-ID: <20101003.215135.226770910.davem@davemloft.net>
References: <1285985695.2582.521.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39878
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751728Ab0JDEvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 00:51:13 -0400
In-Reply-To: <1285985695.2582.521.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 02 Oct 2010 04:14:55 +0200

> No need to get a reference on reg_dev and release it, we are in a
> rcu_read_lock() protected section.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
