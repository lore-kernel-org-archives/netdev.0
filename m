From: Nelson Chang <nelson.chang@mediatek.com>
Subject: RE: [PATCH net-next v2 0/3] net: ethernet: mediatek: add HW LRO
 functions
Date: Sat, 17 Sep 2016 23:50:06 +0800
Message-ID: <1474127406.12937.3.camel@mtksdaap41>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <john@phrozen.org>, <f.fainelli@gmail.com>, <nbd@openwrt.org>,
        <netdev@vger.kernel.org>, <linux-mediatek@lists.infradead.org>,
        <nelsonch.tw@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:46635 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752389AbcIQPuN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 11:50:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks David!
I'll respin the patch and submit the newer version.

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Saturday, September 17, 2016 9:46 PM
To: Nelson Chang (張家祥)
Cc: john@phrozen.org; f.fainelli@gmail.com; nbd@openwrt.org;
netdev@vger.kernel.org; linux-mediatek@lists.infradead.org;
nelsonch.tw@gmail.com
Subject: Re: [PATCH net-next v2 0/3] net: ethernet: mediatek: add HW LRO
functions

From: Nelson Chang <nelson.chang@mediatek.com>
Date: Wed, 14 Sep 2016 13:58:56 +0800

> The series add the large receive offload (LRO) functions by hardware 
> and the ethtool functions to configure RX flows of HW LRO.
> 
> changes since v2:
> - Add ndo_fix_features to prevent NETIF_F_LRO off while RX flow is 
> programmed
> - Rephrase the dts property is a capability if the hardware supports 
> LRO
> 
> changes since v1:
> - Add HW LRO support
> - Add ethtool hooks to set LRO RX flows

This doesn't apply cleanly to net-next.
