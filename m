From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "net: bcmgenet: Remove init parameter from
 bcmgenet_mii_config"
Date: Mon, 31 Jul 2017 18:03:53 -0700 (PDT)
Message-ID: <20170731.180353.963336710039140069.davem@davemloft.net>
References: <20170731180532.19884-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48812 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751607AbdHABDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 21:03:54 -0400
In-Reply-To: <20170731180532.19884-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 31 Jul 2017 11:05:32 -0700

> This reverts commit 28b45910ccda ("net: bcmgenet: Remove init parameter
> from bcmgenet_mii_config") because in the process of moving from
> dev_info() to dev_info_once() we essentially lost the helpful printed
> messages once the second instance of the driver is loaded.
> dev_info_once() does not actually print the message once per device
> instance, but once period.
> 
> Fixes: 28b45910ccda ("net: bcmgenet: Remove init parameter from bcmgenet_mii_config")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
