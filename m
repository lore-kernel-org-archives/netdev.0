From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: Functions to report space available
 in device TX queues
Date: Mon, 25 Aug 2014 17:33:25 -0700 (PDT)
Message-ID: <20140825.173325.723351409734098574.davem@davemloft.net>
References: <alpine.DEB.2.02.1408250823440.31745@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756712AbaHZAd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:33:26 -0400
In-Reply-To: <alpine.DEB.2.02.1408250823440.31745@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 25 Aug 2014 08:27:56 -0700 (PDT)

> This patch adds netdev_tx_avail_queue and netdev_avail_queue which are
> used to report number of bytes available in transmit queues per BQL. The
> functions call dql_avail which returns BQL limit minus number of
> inflight bytes. These functions can be called without txlock, for
> instance to ascertain how much data should be dequeued from a qdisc in
> a batch. When called without the tx_lock, the result is technically a
> hint, subsequently when the tx_lock is done for a transmit it is
> possible the availability has changed (for example a transmit
> completion may have freed up more space in the queue or changed the
> limit).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Ok this looks fine, but could you please resubmit this alongside
the first use case?

Thanks.
