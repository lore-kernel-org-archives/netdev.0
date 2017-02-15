From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: acl: Use PBS type for forward action
Date: Wed, 15 Feb 2017 13:23:43 -0500 (EST)
Message-ID: <20170215.132343.1272582725737502735.davem@davemloft.net>
References: <1487156991-11182-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37040 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752468AbdBOSXp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 13:23:45 -0500
In-Reply-To: <1487156991-11182-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 15 Feb 2017 12:09:51 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Current behaviour of "mirred redirect" action (forward) offload is a bit
> odd. For matched packets the action forwards them to the desired
> destination, but it also lets the packet duplicates to go the original
> way down (bridge, router, etc). That is more like "mirred mirror".
> Fix this by using PBS type which behaves exactly like "mirred redirect".
> Note that PBS does not support loopback mode.
> 
> Fixes: 4cda7d8d7098 ("mlxsw: core: Introduce flexible actions support")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>

Applied, thanks.
