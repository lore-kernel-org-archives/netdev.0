From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] pktgen: fix xmit test for BQL enabled devices
Date: Mon, 07 Apr 2014 15:21:07 -0400 (EDT)
Message-ID: <20140407.152107.1472401551442330093.davem@davemloft.net>
References: <1396883910-3064-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718AbaDGTVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 15:21:09 -0400
In-Reply-To: <1396883910-3064-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon,  7 Apr 2014 17:18:30 +0200

> Similarly as in commit 8e2f1a63f221 ("packet: fix packet_direct_xmit
> for BQL enabled drivers"), we test for __QUEUE_STATE_STACK_XOFF bit
> in pktgen's xmit, which would not fully fill the device's TX ring for
> BQL drivers that use netdev_tx_sent_queue(). Fix is to use, similarly
> as we do in packet sockets, netif_xmit_frozen_or_drv_stopped() test.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks a lot Daniel.
