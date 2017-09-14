From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netvsc: increase default receive buffer size
Date: Thu, 14 Sep 2017 10:02:03 -0700 (PDT)
Message-ID: <20170914.100203.1656028222884493229.davem@davemloft.net>
References: <20170914163107.8404-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, netdev@vger.kernel.org,
        devel@linuxdriverproject.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52250 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751419AbdINRCE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 13:02:04 -0400
In-Reply-To: <20170914163107.8404-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 14 Sep 2017 09:31:07 -0700

> The default receive buffer size was reduced by recent change
> to a value which was appropriate for 10G and Windows Server 2016.
> But the value is too small for full performance with 40G on Azure.
> Increase the default back to maximum supported by host.
> 
> Fixes: 8b5327975ae1 ("netvsc: allow controlling send/recv buffer size")
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

What other side effects are there to making this buffer so large?

Just curious...
