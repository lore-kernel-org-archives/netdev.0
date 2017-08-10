From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: systemport: Fix software statistics for
 SYSTEMPORT Lite
Date: Wed, 09 Aug 2017 22:39:33 -0700 (PDT)
Message-ID: <20170809.223933.897093227475882500.davem@davemloft.net>
References: <20170808214509.26252-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51810 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751346AbdHJFje (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 01:39:34 -0400
In-Reply-To: <20170808214509.26252-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue,  8 Aug 2017 14:45:09 -0700

> With SYSTEMPORT Lite we have holes in our statistics layout that make us
> skip over the hardware MIB counters, bcm_sysport_get_stats() was not
> taking that into account resulting in reporting 0 for all SW-maintained
> statistics, fix this by skipping accordingly.
> 
> Fixes: 44a4524c54af ("net: systemport: Add support for SYSTEMPORT Lite")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
