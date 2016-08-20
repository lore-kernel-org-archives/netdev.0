From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] net: dsa: bcm_sf2: Platform conversion
Date: Fri, 19 Aug 2016 17:16:28 -0700 (PDT)
Message-ID: <20160819.171628.1669783604370003928.davem@davemloft.net>
References: <1471559416-13249-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56004 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755580AbcHTAQ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 20:16:29 -0400
In-Reply-To: <1471559416-13249-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 18 Aug 2016 15:30:11 -0700

> This patch series converts the bcm_sf2 driver from a traditional DSA driver
> into a platform_device driver and makes it use the new DSA binding that Andrew
> introduced in the latest merge window.
> 
> Prior attempts used to coerce the code in net/dsa/dsa2.c to accept the old
> binding, while really there is only one broken single user out there: bcm_sf2,
> so instead, just assume the new DT binding is deployed and use it accordingly.

Series applied, thanks Florian.
