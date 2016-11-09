From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-ipv6: on device mtu change do not add mtu to
 mtu-less routes
Date: Wed, 09 Nov 2016 13:20:38 -0500 (EST)
Message-ID: <20161109.132038.703907726217904996.davem@davemloft.net>
References: <1478296314-32396-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: maze@google.com, netdev@vger.kernel.org, edumazet@google.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38210 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751202AbcKISUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:20:40 -0500
In-Reply-To: <1478296314-32396-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej ¯enczykowski <zenczykowski@gmail.com>
Date: Fri,  4 Nov 2016 14:51:54 -0700

> From: Maciej ¯enczykowski <maze@google.com>
> 
> Routes can specify an mtu explicitly or inherit the mtu from
> the underlying device - this inheritance is implemented in
> dst->ops->mtu handlers ip6_mtu() and ip6_blackhole_mtu().
> 
> Currently changing the mtu of a device adds mtu explicitly
> to routes using that device.
 ...
> This is desirable because changing device mtu and then resetting it
> to the previous value shouldn't change the user visible routing table.
> 
> Signed-off-by: Maciej ¯enczykowski <maze@google.com>

Applied, thank you.
