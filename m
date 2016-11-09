From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] driver: macvlan: Destroy new macvlan port if
 macvlan_common_newlink failed.
Date: Wed, 09 Nov 2016 13:18:35 -0500 (EST)
Message-ID: <20161109.131835.328789401492370826.davem@davemloft.net>
References: <1478226529-26766-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38172 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751546AbcKISSg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:18:36 -0500
In-Reply-To: <1478226529-26766-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Fri,  4 Nov 2016 10:28:49 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> When there is no existing macvlan port in lowdev, one new macvlan port
> would be created. But it doesn't be destoried when something failed later.
> It casues some memleak.
> 
> Now add one flag to indicate if new macvlan port is created.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Looks good, applied, thanks.
