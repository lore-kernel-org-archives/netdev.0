From: David Miller <davem@davemloft.net>
Subject: Re: PPPOE lockdep report in dev_queue_xmit+0x8b8/0x900
Date: Tue, 19 Feb 2013 14:34:25 -0500 (EST)
Message-ID: <20130219.143425.2168723550194243266.davem@davemloft.net>
References: <1361217052.19353.101.camel@edumazet-glaptop>
	<1361272221.2282.5.camel@d2>
	<1361299323.19353.156.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yaneti@declera.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35630 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933179Ab3BSTe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 14:34:26 -0500
In-Reply-To: <1361299323.19353.156.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Feb 2013 10:42:03 -0800

> [PATCH v2] ppp: set qdisc_tx_busylock to avoid LOCKDEP splat
> 
> If a qdisc is installed on a ppp device, its possible to get
> a lockdep splat under stress, because nested dev_queue_xmit() can
> lock busylock a second time (on a different device, so its a false
> positive)
> 
> Avoid this problem using a distinct lock_class_key for ppp
> devices.
> 
> Reported-by: Yanko Kaneti <yaneti@declera.com>
> Tested-by: Yanko Kaneti <yaneti@declera.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
