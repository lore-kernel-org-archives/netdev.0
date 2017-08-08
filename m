From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: systemport: Fix software statistics for
 SYSTEMPORT Lite
Date: Tue, 08 Aug 2017 14:54:47 -0700 (PDT)
Message-ID: <20170808.145447.1322298332754204935.davem@davemloft.net>
References: <20170808213925.26126-1-f.fainelli@gmail.com>
        <f7f79e92-952d-59c6-a0f5-0d9f961a2d8f@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55574 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751919AbdHHVys (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 17:54:48 -0400
In-Reply-To: <f7f79e92-952d-59c6-a0f5-0d9f961a2d8f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 8 Aug 2017 14:44:40 -0700

> On 08/08/2017 02:39 PM, Florian Fainelli wrote:
>> With SYSTEMPORT Lite we have holes in our statistics layout that make us
>> skip over the hardware MIB counters, bcm_sysport_get_stats() was not
>> taking that into account, resulting in reporting 0 for all SW-maintained
>> statistics, fix this by skipping accordingly.
>> 
>> Fixes: 44a4524c54af ("net: systemport: Add support for SYSTEMPORT Lite")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> David, please ignore this version, I accidentally sent it with the
> debugging left.

Ok.
