From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net-next 0/3] net: bcmgenet: only use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 26 Sep 2016 14:18:07 -0700
Message-ID: <b02b7e31-16d0-d1c1-a62d-0045608cabe0@gmail.com>
References: <1474921917-4773-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, jaedon.shin@gmail.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33935 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750977AbcIZVSK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 17:18:10 -0400
In-Reply-To: <1474921917-4773-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2016 01:31 PM, Philippe Reynes wrote:
> Some times ago, a serie of patches were committed :
> - commit 62469c76007e ("net: ethernet: bcmgenet: use phydev from struct net_device")
> - commit 6b352ebccbcf ("net: ethernet: broadcom: bcmgenet: use new api ethtool_{get|set}_link_ksettings")
> The first patch add a regression on this driver, so it should be reverted.
> As the second patch depend on the former, it should be reverted too.
> 
> The first patch is buggy because there is a "trick" in this driver.
> The structure phydev is kept in the private data when the interface
> go down, and used when the interface go up to enable the phy before
> the function phy_connect is called.
> 
> I don't have this hardware, neither the datasheet. So I won't
> update the driver to avoid this trick.
> 
> But the real goal of the first serie was to move to the new api
> ethtool_{get|set}_link_ksettings. So I provide a new version of
> the patch without the "cleaning" of driver to use the phydev
> store in the net_device structure.

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
-- 
Florian
