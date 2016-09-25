From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Revert "net: ethernet: bcmgenet: use phydev
 from struct net_device"
Date: Sun, 25 Sep 2016 05:35:31 -0400 (EDT)
Message-ID: <20160925.053531.2196576594458792866.davem@davemloft.net>
References: <1474772772-5544-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46360 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965572AbcIYJfe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 05:35:34 -0400
In-Reply-To: <1474772772-5544-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat, 24 Sep 2016 20:06:12 -0700

> This reverts commit 62469c76007e ("net: ethernet: bcmgenet: use phydev
> from struct net_device") because it causes GENETv1/2/3 adapters to
> expose the following behavior after an ifconfig down/up sequence:

This breaks the conversion of this driver to ethtool ksettings.

I cannot apply this.
