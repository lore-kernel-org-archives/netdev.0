From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vlan: Keep NETIF_F_HW_CSUM similar to other
 software devices
Date: Mon, 08 May 2017 14:39:36 -0400 (EDT)
Message-ID: <20170508.143936.2240195935826274116.davem@davemloft.net>
References: <1494015461-12192-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mkubecek@suse.cz,
        alexander.duyck@gmail.com, avagin@openvz.org, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34040 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753837AbdEHSji (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 14:39:38 -0400
In-Reply-To: <1494015461-12192-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Fri,  5 May 2017 16:17:41 -0400

> Vlan devices, like all other software devices, enable
> NETIF_F_HW_CSUM feature.  However, unlike all the othe other
> software devices, vlans will switch to using IP|IPV6_CSUM
> features, if the underlying devices uses them.  In these situations,
> checksum offload features on the vlan device can't be controlled
> via ethtool.
> 
> This patch makes vlans keep HW_CSUM feature if the underlying
> device supports checksum offloading.  This makes vlan devices
> behave like other software devices, and restores control to the
> user.
> 
> A side-effect is that some offload settings (typically UFO)
> may be enabled on the vlan device while being disabled on the HW.
> However, the GSO code will correctly process the packets. This
> actually results in slightly better raw throughput.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
> V2:  posted the right patch.

Applied, thanks.
