From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: Initialize ds->cpu_port_mask earlier
Date: Mon, 24 Jul 2017 17:36:54 -0700 (PDT)
Message-ID: <20170724.173654.774517488532007368.davem@davemloft.net>
References: <20170724174923.29156-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sean.wang@mediatek.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45416 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752458AbdGYAg4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 20:36:56 -0400
In-Reply-To: <20170724174923.29156-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 24 Jul 2017 10:49:23 -0700

> The mt7530 driver has its dsa_switch_ops::get_tag_protocol function
> check ds->cpu_port_mask to issue a warning in case the configured CPU
> port is not capable of supporting tags.
> 
> After commit 14be36c2c96c ("net: dsa: Initialize all CPU and enabled
> ports masks in dsa_ds_parse()") we slightly re-arranged the
> initialization such that this was no longer working. Just make sure that
> ds->cpu_port_mask is set prior to the first call to get_tag_protocol,
> thus restoring the expected contract. In case of error, the CPU port bit
> is cleared.
> 
> Fixes: 14be36c2c96c ("net: dsa: Initialize all CPU and enabled ports masks in dsa_ds_parse()")
> Reported-by: Sean Wang <sean.wang@mediatek.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
