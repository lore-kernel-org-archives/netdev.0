From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: dsa: add port fast ageing
Date: Fri, 23 Sep 2016 08:01:50 -0400 (EDT)
Message-ID: <20160923.080150.847812923363318699.davem@davemloft.net>
References: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        john@phrozen.org
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51732 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034027AbcIWMBy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 08:01:54 -0400
In-Reply-To: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 22 Sep 2016 16:49:20 -0400

> Today the DSA drivers are in charge of flushing the MAC addresses
> associated to a port when its STP state changes from Learning or
> Forwarding, to Disabled or Blocking or Listening.
> 
> This makes the drivers more complex and hides this generic switch logic.
> 
> This patchset introduces a new optional port_fast_age operation to
> dsa_switch_ops, to move this logic to the DSA layer and keep drivers
> simple. b53 and mv88e6xxx are updated accordingly.

Series applied, thanks.
