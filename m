From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: spectrum_router: Adjust placement of
 FIB abort warning
Date: Wed, 16 Nov 2016 15:18:26 -0500 (EST)
Message-ID: <20161116.151826.139954270912785247.davem@davemloft.net>
References: <1479286318-6115-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50282 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753955AbcKPUSc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 15:18:32 -0500
In-Reply-To: <1479286318-6115-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 16 Nov 2016 09:51:58 +0100

> From: Ido Schimmel <idosch@mellanox.com>
> 
> The recent merge commit bb598c1b8c9b ("Merge
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net") would cause
> the FIB abort warning to fire whenever we flush the FIB tables - either
> during module removal or actual abort.
> 
> Move it back to its rightful location in the FIB abort function.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks for fixing this up.
