From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] net: bcmgenet: utilize MDIO unimac driver
Date: Mon, 31 Jul 2017 14:41:19 -0700 (PDT)
Message-ID: <20170731.144119.1261443747903049163.davem@davemloft.net>
References: <20170731190429.24204-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com, jaedon.shin@gmail.com,
        pgynther@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45996 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751017AbdGaVlU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 17:41:20 -0400
In-Reply-To: <20170731190429.24204-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 31 Jul 2017 12:04:21 -0700

> Hi all,
> 
> This patch series migrates the Broadcom GENET driver to use the mdio-bcm-unimac
> driver. This MDIO HW is the same as the one GENET internally embedds, yet for
> historical reasons the two drivers lived their own lives. Because of the GENET
> interrupt situation, we let it specify how it wants to signal MDIO operations
> completion using its driver-private waitqueue.
> 
> The diffstat is not super impressive, but it's still negative! This would
> make it easier in the future to absorb possible workarounds/bugs/features
> within the same location.
> 
> This was tested on BCM7260 (GENETv5, single instance), BCM7439 (GENETv4, triple
> instance) and BCM7445 (bcm_sf2 + mdio-bcm-unimac).
> 
> We also now have a nice /proc/iomem output:
> 
> f0b00000-f0b0fc4b : /rdb/ethernet@f0b00000
>   f0b00e14-f0b00e1c : unimac-mdio.0
> f0b20000-f0b2fc4b : /rdb/ethernet@f0b20000
>   f0b20e14-f0b20e1c : unimac-mdio.1
> f0b40000-f0b4fc4b : /rdb/ethernet@f0b40000
>   f0b40e14-f0b40e1c : unimac-mdio.2

I love cleanups like this... even if the diffstat breaks even :-)

Applied, thanks.
