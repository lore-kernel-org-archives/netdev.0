From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] net: make ndo_get_stats64 a void
 function
Date: Sun, 08 Jan 2017 18:14:04 -0500 (EST)
Message-ID: <20170108.181404.448354698697910280.davem@davemloft.net>
References: <20170107031253.2739-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44206 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933989AbdAHXOJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 18:14:09 -0500
In-Reply-To: <20170107031253.2739-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri,  6 Jan 2017 19:12:52 -0800

> The network device operation for reading statistics is only called
> in one place, and it ignores the return value. Having a structure
> return value is potentially confusing because some future driver could
> incorrectly assume that the return value was used.
> 
> Fix all drivers with ndo_get_stats64 to have a void function.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
