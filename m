From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 3/3] sunvnet: Schedule maybe_tx_wakeup() as
 a tasklet from ldc_rx path
Date: Wed, 13 Aug 2014 16:34:29 -0700 (PDT)
Message-ID: <20140813.163429.2256509090025006188.davem@davemloft.net>
References: <20140813142941.GD16865@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbaHMXea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 19:34:30 -0400
In-Reply-To: <20140813142941.GD16865@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 13 Aug 2014 10:29:41 -0400

> At the tail of vnet_event(), if we hit the maybe_tx_wakeup()
> condition, we try to take the netif_tx_lock() in the
> recv-interrupt-context and can deadlock with dev_watchdog().
> vnet_event() should schedule maybe_tx_wakeup() as a tasklet
> to avoid this deadlock
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Applied, thanks.
