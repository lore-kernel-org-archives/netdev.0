From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipmr, ip6mr: return lastuse relative to now
Date: Wed, 21 Sep 2016 00:58:52 -0400 (EDT)
Message-ID: <20160921.005852.936153523920810508.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6DB0104872@AcuExch.aculab.com>
        <1474381042-15344-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        sashok@cumulusnetworks.com, David.Laight@ACULAB.COM
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750738AbcIUE6z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 00:58:55 -0400
In-Reply-To: <1474381042-15344-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Tue, 20 Sep 2016 16:17:22 +0200

> When I introduced the lastuse member I made a subtle error because it was
> returned as an absolute value but that is meaningless to user-space as it
> doesn't allow to see how old exactly an entry is. Let's make it similar to
> how the bridge returns such values and make it relative to "now" (jiffies).
> This allows us to show the actual age of the entries and is much more
> useful (e.g. user-space daemons can age out entries, iproute2 can display
> the lastuse properly).
> 
> Fixes: 43b9e1274060 ("net: ipmr/ip6mr: add support for keeping an entry age")
> Reported-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v2: make sure lastuse is before or equal to jiffies as per David Laight's
> comment

Applied.
