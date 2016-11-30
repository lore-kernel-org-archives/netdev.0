From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2] neigh: remove duplicate check for same neigh
Date: Wed, 30 Nov 2016 13:46:36 -0500 (EST)
Message-ID: <20161130.134636.1025832193501844293.davem@davemloft.net>
References: <1480476282-3650-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39056 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752668AbcK3Sqm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 13:46:42 -0500
In-Reply-To: <1480476282-3650-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Wed, 30 Nov 2016 11:24:42 +0800

> Currently loop index 'idx' is used as the index in the neigh list of interest.
> It's increased only when the neigh is dumped. It's not the absolute index in
> the list. Because there is no info to record which neigh has already be scanned
> by previous loop. This will cause the filtered out neighs to be scanned mulitple
> times.
> 
> This patch make idx as the absolute index in the list, it will increase no matter
> whether the neigh is filtered. This will prevent the above problem.
> 
> And this is in line with other dump functions.
> 
> v2:
>  - take David Ahern's advice to do simple change
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied, thanks.
