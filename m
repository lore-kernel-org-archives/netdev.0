From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: Bring back device detaching in
 dsa_slave_suspend()
Date: Wed, 25 Jan 2017 14:48:12 -0500 (EST)
Message-ID: <20170125.144812.1720429757967902440.davem@davemloft.net>
References: <20170125171041.21442-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33620 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751513AbdAYTsO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:48:14 -0500
In-Reply-To: <20170125171041.21442-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 25 Jan 2017 09:10:41 -0800

> Commit 448b4482c671 ("net: dsa: Add lockdep class to tx queues to avoid
> lockdep splat") removed the netif_device_detach() call done in
> dsa_slave_suspend() which is necessary, and paired with a corresponding
> netif_device_attach(), bring it back.
> 
> Fixes: 448b4482c671 ("net: dsa: Add lockdep class to tx queues to avoid lockdep splat")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> David,
> 
> Can you also queue this for -stable? Thanks!

Applied and queued up for -stable, thanks.
