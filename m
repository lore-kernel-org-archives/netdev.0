From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] net/sched: fix missing spinlock init
Date: Thu, 21 Oct 2010 03:10:54 -0700 (PDT)
Message-ID: <20101021.031054.193713521.davem@davemloft.net>
References: <1287206554.2799.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52635
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751281Ab0JUKKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:10:31 -0400
In-Reply-To: <1287206554.2799.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 16 Oct 2010 07:22:34 +0200

> Under network load, doing :
> 
> tc qdisc del dev eth0 root
> 
> triggers :
 ...
> commit 79640a4ca695 (add additional lock to qdisc to increase
> throughput) forgot to initialize  noop_qdisc and noqueue_qdisc busylock 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Applied.
