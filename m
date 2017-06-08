From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: ipmr: add getlink support
Date: Thu, 08 Jun 2017 14:39:13 -0400 (EDT)
Message-ID: <20170608.143913.800862231155819238.davem@davemloft.net>
References: <1496767292-7976-1-git-send-email-nikolay@cumulusnetworks.com>
        <1496847752-6935-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        sharpd@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34244 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751344AbdFHSjP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 14:39:15 -0400
In-Reply-To: <1496847752-6935-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Wed,  7 Jun 2017 18:02:32 +0300

> Currently there's no way to dump the VIF table for an ipmr table other
> than the default (via proc). This is a major issue when debugging ipmr
> issues and in general it is good to know which interfaces are
> configured. This patch adds support for RTM_GETLINK for the ipmr family
> so we can dump the VIF table and the ipmr table's current config for
> each table. We're protected by rtnl so no need to acquire RCU or
> mrt_lock.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v2: use netlink attributes for all mrtable and vif fields, and set message
>     type to RTM_NEWLINK
> 
> The plan is to add full netlink control to ipmr via new/set/dellink later.
> Also this would allow us to dump any number of VIFs in the future when we
> remove the VIF device limit.

Applied, thanks Nikolay.
