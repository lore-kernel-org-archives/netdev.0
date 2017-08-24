From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/2] net: dsa: Fix tag_ksz.c
Date: Wed, 23 Aug 2017 20:37:25 -0700 (PDT)
Message-ID: <20170823.203725.2147193612476095021.davem@davemloft.net>
References: <20170822221215.16305-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, UNGLinuxDriver@microchip.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58214 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdHXDh0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 23:37:26 -0400
In-Reply-To: <20170822221215.16305-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 22 Aug 2017 15:12:13 -0700

> This implements David's suggestion of providing low-level functions
> to control whether skb_pad() and skb_put_padto() should be freeing
> the passed skb.
> 
> We make use of it to fix a double free in net/dsa/tag_ksz.c that would
> occur if we kept using skb_put_padto() in both places.

Series applied and queued up for -stable, thanks.
