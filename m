From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio-net: use netif_tx_napi_add for tx napi
Date: Sun, 30 Apr 2017 22:33:19 -0400 (EDT)
Message-ID: <20170430.223319.1119913439601554176.davem@davemloft.net>
References: <20170428003758.48143-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54270 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162752AbdEACdV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:33:21 -0400
In-Reply-To: <20170428003758.48143-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Thu, 27 Apr 2017 20:37:58 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Avoid hashing the tx napi struct into napi_hash[], which is used for
> busy polling receive queues.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied.
