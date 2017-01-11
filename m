From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: Ensure validity of dst->ds[0]
Date: Tue, 10 Jan 2017 20:19:58 -0500 (EST)
Message-ID: <20170110.201958.2241956529987896253.davem@davemloft.net>
References: <20170109195834.11697-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33552 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752929AbdAKBUA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 20:20:00 -0500
In-Reply-To: <20170109195834.11697-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon,  9 Jan 2017 11:58:34 -0800

> It is perfectly possible to have non zero indexed switches being present
> in a DSA switch tree, in such a case, we will be deferencing a NULL
> pointer while dsa_cpu_port_ethtool_{setup,restore}. Be more defensive
> and ensure that dst->ds[0] is valid before doing anything with it.
> 
> Fixes: 0c73c523cf73 ("net: dsa: Initialize CPU port ethtool ops per tree")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks.
