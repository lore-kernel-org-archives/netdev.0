From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tilepro: Fix non-void return from void function
Date: Thu, 12 Jan 2017 15:14:28 -0500 (EST)
Message-ID: <20170112.151428.219165181835416547.davem@davemloft.net>
References: <fb9071cb1b950cd3328d838f511231d11d07990c.1484175023.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmetcalf@mellanox.com, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56356 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751158AbdALUOa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:14:30 -0500
In-Reply-To: <fb9071cb1b950cd3328d838f511231d11d07990c.1484175023.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 11 Jan 2017 14:52:20 -0800

> commit bc1f44709cf2 ("net: make ndo_get_stats64 a void function")
> mistakenly used a return value for this void conversion.
> 
> Fix it.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> cc: stephen hemminger <stephen@networkplumber.org>

Applied.
