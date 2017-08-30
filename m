From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: Do not return from void
 function
Date: Tue, 29 Aug 2017 22:40:15 -0700 (PDT)
Message-ID: <20170829.224015.1227807707707968405.davem@davemloft.net>
References: <20170830044851.20348-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@daveloft.net, opendmb@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46270 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdH3FkP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 01:40:15 -0400
In-Reply-To: <20170830044851.20348-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 29 Aug 2017 21:48:51 -0700

> A stray return was added in the macro bcmgenet_##name##_writel where it
> should not, drop it.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: 69d2ea9c7989 ("net: bcmgenet: Use correct I/O accessors")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
