From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: remove useless memset's in drivers
 get_stats64
Date: Sun, 08 Jan 2017 18:14:09 -0500 (EST)
Message-ID: <20170108.181409.566688574792215066.davem@davemloft.net>
References: <20170107031253.2739-1-sthemmin@microsoft.com>
        <20170107031253.2739-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44212 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdAHXOL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 18:14:11 -0500
In-Reply-To: <20170107031253.2739-2-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri,  6 Jan 2017 19:12:53 -0800

> In dev_get_stats() the statistic structure storage has already been
> zeroed. Therefore network drivers do not need to call memset() again.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
