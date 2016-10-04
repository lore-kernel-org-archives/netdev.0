From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: Wake queue from reset work
Date: Tue, 04 Oct 2016 00:36:40 -0400 (EDT)
Message-ID: <20161004.003640.2123697293503989553.davem@davemloft.net>
References: <20161003024750.30015-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, skhare@vmware.com, pv-drivers@vmware.com
To: bpoirier@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54252 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751150AbcJDEgw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 00:36:52 -0400
In-Reply-To: <20161003024750.30015-1-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>
Date: Mon,  3 Oct 2016 10:47:50 +0800

> vmxnet3_reset_work() expects tx queues to be stopped (via
> vmxnet3_quiesce_dev -> netif_tx_disable). However, this races with the
> netif_wake_queue() call in netif_tx_timeout() such that the driver's
> start_xmit routine may be called unexpectedly, triggering one of the BUG_ON
> in vmxnet3_map_pkt with a stack trace like this:
 ...
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

Applied, thanks.
