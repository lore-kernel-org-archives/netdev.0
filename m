From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] driver: macvlan: Check if need rollback
 multicast setting in macvlan_open
Date: Wed, 23 Nov 2016 20:26:49 -0500 (EST)
Message-ID: <20161123.202649.1918521321796603041.davem@davemloft.net>
References: <1479779676-10417-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41854 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935508AbcKXB0w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 20:26:52 -0500
In-Reply-To: <1479779676-10417-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Tue, 22 Nov 2016 09:54:36 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> When dev_set_promiscuity failed in macvlan_open, it always invokes
> dev_set_allmulti without checking if necessary.
> Now check the IFF_ALLMULTI flag firstly before rollback the multicast
> setting in the error handler.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
