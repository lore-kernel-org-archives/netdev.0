From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: Do not suspend PHY if Wake-on-LAN
 is enabled
Date: Wed, 15 Mar 2017 15:36:17 -0700 (PDT)
Message-ID: <20170315.153617.1526671706541609729.davem@davemloft.net>
References: <20170315195721.11507-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com, pgynther@google.com,
        jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55320 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754113AbdCOWhn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 18:37:43 -0400
In-Reply-To: <20170315195721.11507-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 15 Mar 2017 12:57:21 -0700

> Suspending the PHY would be putting it in a low power state where it
> may no longer allow us to do Wake-on-LAN.
> 
> Fixes: cc013fb48898 ("net: bcmgenet: correctly suspend and resume PHY device")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks!
