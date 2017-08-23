From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net v2 1/2] net: core: Specify skb_pad()/skb_put_padto()
 SKB freeing
Date: Wed, 23 Aug 2017 21:42:18 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B05FD6@CHN-SV-EXMX02.mchp-main.com>
References: <20170822221215.16305-1-f.fainelli@gmail.com>
 <20170822221215.16305-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>
To: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa1.microchip.iphmx.com ([68.232.147.91]:33923 "EHLO
        esa1.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751104AbdHWVnR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 17:43:17 -0400
In-Reply-To: <20170822221215.16305-2-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Cc: davem@davemloft.net; vivien.didelot@savoirfairelinux.com; Woojung
> Huh - C21699; UNGLinuxDriver; Florian Fainelli
> Subject: [PATCH net v2 1/2] net: core: Specify skb_pad()/skb_put_padto()
> SKB freeing
> 
> Rename skb_pad() into __skb_pad() and make it take a third argument:
> free_on_error which controls whether kfree_skb() should be called or
> not, skb_pad() directly makes use of it and passes true to preserve its
> existing behavior. Do exactly the same thing with __skb_put_padto() and
> skb_put_padto().
> 
> Suggested-by: David Miller <davem@davemloft.net>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Woojung Huh <Woojung.Huh@microchip.com>

- Woojung
