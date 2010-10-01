From: David Miller <davem@davemloft.net>
Subject: Re: PATCH net-next 1/2] ipv4: introduce __ip_dev_find()
Date: Thu, 30 Sep 2010 21:17:08 -0700 (PDT)
Message-ID: <20100930.211708.216741810.davem@davemloft.net>
References: <1285853516.2615.515.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48272
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751176Ab0JAEQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 00:16:48 -0400
In-Reply-To: <1285853516.2615.515.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 30 Sep 2010 15:31:56 +0200

> ip_dev_find(net, addr) finds a device given an IPv4 source address and
> takes a reference on it.
> 
> Introduce __ip_dev_find(), taking a third argument, to optionally take
> the device reference. Callers not asking the reference to be taken
> should be in an rcu_read_lock() protected section.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
