From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next v2 11/12] net: ethernet: aquantia: Fixed memory
 allocation if AQ_CFG_RX_FRAME_MAX > 1 page.
Date: Sat, 18 Feb 2017 12:50:12 +0100
Message-ID: <a793e89b-d1e2-5cec-cae6-b223c7f8f708@gmx.de>
References: <cover.1487365317.git.pavel.belous@aquantia.com>
 <c45b44987d24c7aae83c796a3731295317ae83f7.1487365317.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:58574 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752088AbdBRLuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 18 Feb 2017 06:50:25 -0500
In-Reply-To: <c45b44987d24c7aae83c796a3731295317ae83f7.1487365317.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 17.02.2017 22:07, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> We should allocate the number of pages based on the config parameter
> AQ_CFG_RX_FRAME_MAX.
> 
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>

>  	do {
>  		if (spin_trylock(&ring->header.lock)) {
> -			frags = aq_nic_map_skb(self, skb, &buffers[0]);
> +			frags = aq_nic_map_skb(self, skb, buffers);
>  
> -			aq_ring_tx_append_buffs(ring, &buffers[0], frags);
> +			aq_ring_tx_append_buffs(ring, buffers, frags);
>  

This change has nothing to do with what the commit message claims that the
patch is about. Please dont mix fixes and totally unrelated cleanups in one
patch.

Regards,
Lino
