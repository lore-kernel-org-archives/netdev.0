From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net] xen-netback: fix guest Rx stall detection (after
 guest Rx refactor)
Date: Thu, 13 Oct 2016 10:21:14 -0400 (EDT)
Message-ID: <20161013.102114.277377641513965761.davem@davemloft.net>
References: <1476200907-16085-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        paul.durrant@citrix.com, wei.liu2@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33224 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932642AbcJMOWv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 10:22:51 -0400
In-Reply-To: <1476200907-16085-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Tue, 11 Oct 2016 16:48:27 +0100

> If a VIF has been ready for rx_stall_timeout (60s by default) and an
> Rx ring is drained of all requests an Rx stall will be incorrectly
> detected.  When this occurs and the guest Rx queue is empty, the Rx
> ring's event index will not be set and the frontend will not raise an
> event when new requests are placed on the ring, permanently stalling
> the VIF.
> 
> This is a regression introduced by eb1723a29b9a7 (xen-netback:
> refactor guest rx).
> 
> Fix this by reinstating the setting of queue->last_rx_time when
> placing a packet onto the guest Rx ring.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied.
