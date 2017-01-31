From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 0/3] net-next: use one struct bgmac & add PHY support
Date: Tue, 31 Jan 2017 14:03:37 -0500 (EST)
Message-ID: <20170131.140337.1302667347068852135.davem@davemloft.net>
References: <20170128210832.26174-1-zajec5@gmail.com>
        <20170131183756.20395-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: jon.mason@broadcom.com, f.fainelli@gmail.com, nbd@openwrt.org,
        netdev@vger.kernel.org, rafal@milecki.pl
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42538 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751844AbdAaTFR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 14:05:17 -0500
In-Reply-To: <20170131183756.20395-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafa©© Mi©©ecki <zajec5@gmail.com>
Date: Tue, 31 Jan 2017 19:37:53 +0100

> From: Rafa©© Mi©©ecki <rafal@milecki.pl>
> 
> This patchset adds support for initializing PHY using PHY subsystem.
> It's required e.g. for wireless access point devices that use bgmac
> supported Ethernet device connected to some external PHY.
> 
> Implementing this required accessing phydev in bcma specific code which
> wasn't possible with core code allocating struct bgmac on its own. This
> is why I needed to modify alloc_etherdev usage first.

Series applied, thanks.
