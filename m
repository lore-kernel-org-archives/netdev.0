From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] mii_bus: increase MII_BUS_ID_SIZE to 61
Date: Fri, 13 Jan 2017 17:31:08 +0100
Message-ID: <20170113163108.GN10203@lunn.ch>
References: <1484320752-32096-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se,
        Magnus =?iso-8859-1?Q?=D6berg?= <magnus.oberg@westermo.se>
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59640 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751924AbdAMQbL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Jan 2017 11:31:11 -0500
Content-Disposition: inline
In-Reply-To: <1484320752-32096-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 04:19:12PM +0100, Volodymyr Bendiuga wrote:
> From: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
> 
> Some bus names are pretty long and do not fit into 20 chars.
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
> Signed-off-by: Magnus Öberg <magnus.oberg@westermo.se>
> ---
>  include/linux/phy.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index feb8a98..b67f94d 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -162,7 +162,7 @@ static inline const char *phy_modes(phy_interface_t interface)
>   * Need to be a little smaller than phydev->dev.bus_id to leave room
>   * for the ":%02x"
>   */
> -#define MII_BUS_ID_SIZE	(20 - 3)
> +#define MII_BUS_ID_SIZE	(64 - 3)

Hi Volodymyr

Humm, i assume you looked at the comment? What is the size of phydev->dev.bus_id?
Is 61 still a little smaller?

      Andrew
