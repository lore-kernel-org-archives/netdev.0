From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio_net: remove custom busy_poll
Date: Fri, 03 Feb 2017 11:14:06 -0500 (EST)
Message-ID: <20170203.111406.1282504592460118826.davem@davemloft.net>
References: <1486046136.13103.42.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, mst@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38284 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750955AbdBCQOH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 11:14:07 -0500
In-Reply-To: <1486046136.13103.42.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Feb 2017 06:35:36 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Generic NAPI busy polling allows us to remove custom implementations
> found in drivers.
> 
> It is possible further optimization could be done by testing
> napi_complete_done() return value.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
