From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: Do not destroy invalid network devices
Date: Wed, 08 Feb 2017 14:51:24 -0500 (EST)
Message-ID: <20170208.145124.384553956748848714.davem@davemloft.net>
References: <20170208071013.19216-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57628 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbdBHTv0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:51:26 -0500
In-Reply-To: <20170208071013.19216-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue,  7 Feb 2017 23:10:13 -0800

> dsa_slave_create() can fail, and dsa_user_port_unapply() will properly check
> for the network device not being NULL before attempting to destroy it. We were
> not setting the slave network device as NULL if dsa_slave_create() failed, so
> we would later on be calling dsa_slave_destroy() on a now free'd and
> unitialized network device, causing crashes in dsa_slave_destroy().
> 
> Fixes: 83c0afaec7b7 ("net: dsa: Add new binding implementation")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks.
