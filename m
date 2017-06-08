From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net 3/3] ethtool.h: remind to update 802.3ad when adding
 new speeds
Date: Thu, 8 Jun 2017 08:56:35 -0400
Message-ID: <20170608125635.GC78114@C02RW35GFVH8.dhcp.broadcom.net>
References: <1496913493-23293-1-git-send-email-nicolas.dichtel@6wind.com>
 <1496913493-23293-3-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
        vfalico@gmail.com, thibaut.collet@6wind.com, linville@tuxdriver.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:36186 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdFHM4h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 08:56:37 -0400
Received: by mail-qt0-f195.google.com with SMTP id s33so7871991qtg.3
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 05:56:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1496913493-23293-3-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 08, 2017 at 11:18:13AM +0200, Nicolas Dichtel wrote:
> Each time a new speed is added, the bonding 802.3ad isn't updated. Add a
> comment to remind the developer to update this driver.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Andy Gospodarek <andy@greyhouse.net>

> ---
>  include/uapi/linux/ethtool.h | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index d179d7767f51..7d4a594d5d58 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -1486,8 +1486,10 @@ enum ethtool_link_mode_bit_indices {
>   * it was forced up into this mode or autonegotiated.
>   */
>  
> -/* The forced speed, in units of 1Mb. All values 0 to INT_MAX are legal. */
> -/* Update drivers/net/phy/phy.c:phy_speed_to_str() when adding new values */
> +/* The forced speed, in units of 1Mb. All values 0 to INT_MAX are legal.
> + * Update drivers/net/phy/phy.c:phy_speed_to_str() and
> + * drivers/net/bonding/bond_3ad.c:__get_link_speed() when adding new values.

A little wide, but not wider than it was before, so that's fine with me.

> + */
>  #define SPEED_10		10
>  #define SPEED_100		100
>  #define SPEED_1000		1000
> -- 
> 2.8.1
> 
