From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdevice: fix sparse warning for HARD_TX_LOCK
Date: Sun, 27 Nov 2016 15:44:39 -0500 (EST)
Message-ID: <20161127.154439.845919200540679482.davem@davemloft.net>
References: <1479963754-24105-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58252 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752693AbcK0Uol (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 15:44:41 -0500
In-Reply-To: <1479963754-24105-1-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 24 Nov 2016 07:04:08 +0200

> sparse warns about context imbalance in any code
> that uses HARD_TX_LOCK/UNLOCK - this is because it's
> unable to determine that flags don't change so
> lock and unlock are paired.
> 
> Seems easy enough to fix by adding __acquire/__release
> calls.
> 
> With this patch af_packet.c is now sparse-clean,
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied to net-next, thanks.
