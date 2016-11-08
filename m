From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] driver: macvlan: Destroy new macvlan port if
 macvlan_common_newlink failed.
Date: Mon, 07 Nov 2016 20:33:32 -0500 (EST)
Message-ID: <20161107.203332.1849719163992933801.davem@davemloft.net>
References: <1478226529-26766-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbcKHBde (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 20:33:34 -0500
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

You need to be more patient, it sometimes take several days before
your get patch reviewed or applied.  Sometimes nobody reviews a change
for some time because it is obscure or everyone is busy.

All patches are tracked in patchwork, so it is never an issue of a
change getting "lost".  Therefore, it never makes sense to ping the
list again and ask if a change is "ok".

Personally, when people ping like that, it makes me want to review
that patch _less_ not more.  So please do not do it.

Thank you.
