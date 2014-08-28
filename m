From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 00/13] dsa: Broadcom Starfighter 2 switch
 support
Date: Wed, 27 Aug 2014 18:30:33 -0700 (PDT)
Message-ID: <20140827.183033.1723409609887880785.davem@davemloft.net>
References: <1409184267-1696-1-git-send-email-f.fainelli@gmail.com>
	<20140827.181229.2168894985069137270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com, jhs@mojatatu.com,
	alexander.duyck@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757014AbaH1Bae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 21:30:34 -0400
In-Reply-To: <20140827.181229.2168894985069137270.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 27 Aug 2014 18:12:29 -0700 (PDT)

> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Wed, 27 Aug 2014 17:04:14 -0700
> 
>> This patch series adds support for the Broadcom Starfighter 2 (Roboswitch
>> successor) using the existing DSA infrastructure. This integrated switch
>> is heavily used in Set Top Box, Cable gateways and DSL gateways products
>> from Broadcom, and to a larger extent the new ARM-based Wi-Fi routers although
>> slightly differently.
> 
> Series applied, thanks Florian.

Florian, I had to make an adjustment to make your series work.

The Tulip dmfe driver internally has static functions named phy_read()
and phy_write().  I had to add a commit to rename them before your
series.

Please when adjusting globally visible interfaces, do an allmodconfig
build to catch these kinds of problems.

Thanks.
