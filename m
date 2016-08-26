From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-v2 0/6] net: dsa: Make bcm_sf2 utilize
 b53_common
Date: Fri, 26 Aug 2016 12:08:30 -0700 (PDT)
Message-ID: <20160826.120830.1882445675319317827.davem@davemloft.net>
References: <1472142282-1479-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jonas.gorski@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59865 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750869AbcHZTJ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 15:09:28 -0400
In-Reply-To: <1472142282-1479-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 25 Aug 2016 09:24:35 -0700

> Hi all,
> 
> This patch series makes the bcm_sf2 driver utilize a large number of the core
> functions offered by the b53_common driver since the SWITCH_CORE registers are
> mostly register compatible with the switches driven by b53_common.
> 
> In order to accomplish that, we just override the dsa_driver_ops callbacks that
> we need to. There are still integration specific logic from the bcm_sf2 that we
> cannot absorb into b53_common because it is just not there, mostly in the area
> of link management and power management, but most of the features are within
> b53_common now: VLAN, FDB, bridge
> 
> Along the process, we also improve support for the BCM58xx SoCs, since those
> also have the same version of the switching IP that 7445 has (for which bcm_sf2
> was developed).
> 
> Changes in v2:
> 
> - rebased against "net: dsa: rename switch operations structure"

This still doesn't apply cleanly to net-next, can you respin it one more
time and double check your work?

Thanks.
