From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] Allow to switch off UDP-based tunnel
 offloads per netdevice
Date: Mon, 24 Jul 2017 13:53:14 -0700 (PDT)
Message-ID: <20170724.135314.220303475857329237.davem@davemloft.net>
References: <cover.1500632570.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com,
        hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42854 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755724AbdGXUxP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 16:53:15 -0400
In-Reply-To: <cover.1500632570.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri, 21 Jul 2017 12:49:27 +0200

> This patchset adds a new netdevice feature to toggle RX offloads of
> UDP-based tunnel via ethtool. This is useful if the offload is causing
> issues, for example if the hardware is buggy.
> 
> The feature is added to all devices providing the ->ndo_udp_tunnel_add
> op, and enabled by default to preserve current behavior.
> 
> When the administrator disables this feature on a device, all
> currently offloaded ports are cleared from the device.  When the
> feature is turned on, the stack notifies the device about all current
> ports.
> 
> v2:
>  - rename feature bit to NETIF_F_RX_UDP_TUNNEL_PORT
>  - rename ethtool feature to rx-udp_tunnel-port-offload

Series applied, thanks Sabrina.
