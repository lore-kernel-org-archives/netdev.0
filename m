From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dp83640: don't hold spinlock while calling
 netif_rx_ni
Date: Wed, 30 Aug 2017 14:50:31 -0700 (PDT)
Message-ID: <20170830.145031.1158341283102125578.davem@davemloft.net>
References: <20170830065847.2444-1-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: stefan.sorensen@spectralink.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34640 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750973AbdH3Vuc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 17:50:32 -0400
In-Reply-To: <20170830065847.2444-1-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Sørensen <stefan.sorensen@spectralink.com>
Date: Wed, 30 Aug 2017 08:58:47 +0200

> We should not hold a spinlock while pushing the skb into the networking
> stack, so move the call to netif_rx_ni out of the critical region to where
> we have dropped the spinlock.
> 
> Signed-off-by: Stefan Sørensen <stefan.sorensen@spectralink.com>

Looks good, applied, thanks.
