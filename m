From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netvsc: fix race during initialization
Date: Thu, 16 Mar 2017 21:35:48 -0700 (PDT)
Message-ID: <20170316.213548.1576100698734340553.davem@davemloft.net>
References: <20170316192132.9095-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbdCQEfy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 00:35:54 -0400
In-Reply-To: <20170316192132.9095-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 16 Mar 2017 12:21:32 -0700

> When device is being setup on boot, there is a small race where
> network device callback is registered, but the netvsc_device pointer
> is not set yet.  This can cause a NULL ptr dereference if packet
> arrives during this window.
> 
> Fixes: 46b4f7f5d1f7 ("netvsc: eliminate per-device outstanding send counter")
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
> Applies to 4.11 only, not in earlier versions.
> net-next needs different patch

Applied, thanks Stephen.
