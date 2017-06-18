From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: Fix legacy probing
Date: Sat, 17 Jun 2017 23:00:07 -0400 (EDT)
Message-ID: <20170617.230007.1693067369502743161.davem@davemloft.net>
References: <20170616234211.20341-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jcobham@questertangent.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45522 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751923AbdFRDAK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 23:00:10 -0400
In-Reply-To: <20170616234211.20341-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 16 Jun 2017 16:42:11 -0700

> After commit 6d3c8c0dd88a ("net: dsa: Remove master_netdev and
> use dst->cpu_dp->netdev") and a29342e73911 ("net: dsa: Associate
> slave network device with CPU port") we would be seeing NULL pointer
> dereferences when accessing dst->cpu_dp->netdev too early. In the legacy
> code, we actually know early in advance the master network device, so
> pass it down to the relevant functions.
> 
> Fixes: 6d3c8c0dd88a ("net: dsa: Remove master_netdev and use dst->cpu_dp->netdev")
> Fixes: a29342e73911 ("net: dsa: Associate slave network device with CPU port")
> Reported-by: Jason Cobham <jcobham@questertangent.com>
> Tested-by: Jason Cobham <jcobham@questertangent.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
