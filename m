From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio-net: on tx, only call napi_disable if
 tx napi is on
Date: Wed, 26 Apr 2017 14:50:23 -0400 (EDT)
Message-ID: <20170426.145023.520426501343191968.davem@davemloft.net>
References: <20170425195917.54209-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59408 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753826AbdDZSuZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:50:25 -0400
In-Reply-To: <20170425195917.54209-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue, 25 Apr 2017 15:59:17 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> As of tx napi, device down (`ip link set dev $dev down`) hangs unless
> tx napi is enabled. Else napi_enable is not called, so napi_disable
> will spin on test_and_set_bit NAPI_STATE_SCHED.
> 
> Only call napi_disable if tx napi is enabled.
> 
> Fixes: 5a719c2552ca ("virtio-net: transmit napi")
> Reported-by: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks.
