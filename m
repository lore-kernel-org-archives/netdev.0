From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: Get VLAN_PORT_MASK from
 b53_device
Date: Sun, 11 Sep 2016 19:37:22 -0700 (PDT)
Message-ID: <20160911.193722.2123183155908368397.davem@davemloft.net>
References: <1473536343-13427-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36950 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756515AbcILCh2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 22:37:28 -0400
In-Reply-To: <1473536343-13427-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat, 10 Sep 2016 12:39:03 -0700

> While migrating the bcm_sf2 driver to use b53_common, we left a small
> piece untouched where we kept our local copy of the per-port
> port_vlan_ctl bitmask value. This value is now maintained by b53_device
> so we need to use it instead of our local (and now stale) copy of it.
> 
> Fixes: f458995b9ad8 ("net: dsa: bcm_sf2: Utilize core B53 driver when possible")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
