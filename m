From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] driver: ipvlan: Fix one possible memleak in
 ipvlan_link_new
Date: Sun, 27 Nov 2016 19:58:56 -0500 (EST)
Message-ID: <20161127.195856.2031792373036023546.davem@davemloft.net>
References: <1480001999-10500-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, edumazet@google.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751093AbcK1A7n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 19:59:43 -0500
In-Reply-To: <1480001999-10500-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Thu, 24 Nov 2016 23:39:59 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> When ipvlan_link_new fails and creates one ipvlan port, it does not
> destroy the ipvlan port created. It causes mem leak and the physical
> device contains invalid ipvlan data.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied, thanks.
