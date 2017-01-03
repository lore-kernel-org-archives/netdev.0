From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipmr, ip6mr: add RTNH_F_UNRESOLVED flag to
 unresolved cache entries
Date: Tue, 03 Jan 2017 10:04:45 -0500 (EST)
Message-ID: <20170103.100445.159677172654029012.davem@davemloft.net>
References: <1483442019-20917-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37500 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757468AbdACPEq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 10:04:46 -0500
In-Reply-To: <1483442019-20917-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Tue,  3 Jan 2017 12:13:39 +0100

> While working with ipmr, we noticed that it is impossible to determine
> if an entry is actually unresolved or its IIF interface has disappeared
> (e.g. virtual interface got deleted). These entries look almost
> identical to user-space when dumping or receiving notifications. So in
> order to recognize them add a new RTNH_F_UNRESOLVED flag which is set when
> sending an unresolved cache entry to user-space.
> 
> Suggested-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This looks fine, applied, thanks.
