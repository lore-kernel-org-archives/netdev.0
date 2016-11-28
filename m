From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] driver: macvtap: Unregister netdev rx_handler
 if macvtap_newlink fails
Date: Sun, 27 Nov 2016 20:04:43 -0500 (EST)
Message-ID: <20161127.200443.986658993214630297.davem@davemloft.net>
References: <1480039506-29740-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35818 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751969AbcK1BEp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 20:04:45 -0500
In-Reply-To: <1480039506-29740-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Fri, 25 Nov 2016 10:05:06 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> The macvtap_newlink registers the netdev rx_handler firstly, but it
> does not unregister the handler if macvlan_common_newlink failed.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
