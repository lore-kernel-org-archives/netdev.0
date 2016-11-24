From: David Miller <davem@davemloft.net>
Subject: Re: [net] rtnetlink: fix the wrong minimal dump size getting from
 rtnl_calcit()
Date: Wed, 23 Nov 2016 20:27:46 -0500 (EST)
Message-ID: <20161123.202746.1996505509083092421.davem@davemloft.net>
References: <1479795268-11801-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41942 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935508AbcKXB1t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 20:27:49 -0500
In-Reply-To: <1479795268-11801-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Tue, 22 Nov 2016 14:14:28 +0800

> For RT netlink, calcit() function should return the minimal size for
> netlink dump message. This will make sure that dump message for every
> network device can be stored.
> 
> Currently, rtnl_calcit() function doesn't account the size of header of
> netlink message, this patch will fix it.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied.
