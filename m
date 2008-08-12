From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Add BH protection for qdisc_stab_lock.
Date: Mon, 11 Aug 2008 18:11:24 -0700 (PDT)
Message-ID: <20080811.181124.209719830.davem@davemloft.net>
References: <20080811214239.GB15293@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59589
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750869AbYHLBLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 21:11:23 -0400
In-Reply-To: <20080811214239.GB15293@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 11 Aug 2008 23:42:39 +0200

> pkt_sched: Add BH protection for qdisc_stab_lock.
> 
> Since qdisc_stab_lock is used in qdisc_put_stab(), which is called in
> BH context from __qdisc_destroy() RCU callback, softirq safe locking
> is needed.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks Jarek.
