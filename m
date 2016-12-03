From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: be less conservative with sock rmem
 accounting
Date: Sat, 03 Dec 2016 16:15:02 -0500 (EST)
Message-ID: <20161203.161502.2062069811901046717.davem@davemloft.net>
References: <d13b9808dad5f6e3fe3808bae3b4f64dfcee07fe.1480696423.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37420 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750873AbcLCVPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 16:15:04 -0500
In-Reply-To: <d13b9808dad5f6e3fe3808bae3b4f64dfcee07fe.1480696423.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri,  2 Dec 2016 17:35:49 +0100

> Before commit 850cbaddb52d ("udp: use it's own memory accounting
> schema"), the udp protocol allowed sk_rmem_alloc to grow beyond
> the rcvbuf by the whole current packet's truesize. After said commit
> we allow sk_rmem_alloc to exceed the rcvbuf only if the receive queue
> is empty. As reported by Jesper this cause a performance regression
> for some (small) values of rcvbuf.
> 
> This commit is intended to fix the regression restoring the old
> handling of the rcvbuf limit.
> 
> Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Fixes: 850cbaddb52d ("udp: use it's own memory accounting schema")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied.
