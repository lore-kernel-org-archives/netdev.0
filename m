From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: Don't dereference dst->cpu_dp->netdev
Date: Mon, 28 Aug 2017 21:20:21 -0700 (PDT)
Message-ID: <20170828.212021.1488966345817697383.davem@davemloft.net>
References: <1503965451-59498-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, dan.carpenter@oracle.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbdH2EUY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 00:20:24 -0400
In-Reply-To: <1503965451-59498-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 28 Aug 2017 17:10:51 -0700

> If we do not have a master network device attached dst->cpu_dp will be
> NULL and accessing cpu_dp->netdev will create a trace similar to the one
> below. The correct check is on dst->cpu_dp period.
 ...
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Fixes: 6d3c8c0dd88a ("net: dsa: Remove master_netdev and use dst->cpu_dp->netdev")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
