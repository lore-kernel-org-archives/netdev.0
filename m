From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dql: make dql_init return void
Date: Thu, 19 Oct 2017 13:34:24 +0100 (WEST)
Message-ID: <20171019.133424.1017702196231164468.davem@davemloft.net>
References: <20171018001652.23740-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, shimoda.hiroaki@gmail.com,
        netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49204 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752384AbdJSMeb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:34:31 -0400
In-Reply-To: <20171018001652.23740-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 17 Oct 2017 17:16:52 -0700

> dql_init always returned 0, and the only place that uses it
> in network core code didn't care about the return value anyway.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied to net-next.
