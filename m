From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/3] net: phy: add module_phy_driver macro
Date: Tue, 11 Nov 2014 11:14:29 -0800
Message-ID: <54626015.3030907@gmail.com>
References: <1415731559-10015-1-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Johan Hovold <johan@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415731559-10015-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/11/2014 10:45 AM, Johan Hovold wrote:
> Add module_phy_driver macro that can be used by PHY drivers that only
> calls phy_driver_register or phy_drivers_register (and the corresponding
> unregister functions) in their module init (and exit).
> 
> This allows us to eliminate a lot of boilerplate code.
> 
> Split in three patches (actual macro and two driver change classes) in
> order to facilitate review.

Looks good to me:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!

> 
> Johan
> 
> 
> Johan Hovold (3):
>   net: phy: add module_phy_driver macro
>   net: phy: replace phy_driver_register calls
>   net: phy: replace phy_drivers_register calls
> 
>  drivers/net/phy/amd-xgbe-phy.c | 15 +--------------
>  drivers/net/phy/amd.c          | 17 +++--------------
>  drivers/net/phy/at803x.c       | 14 +-------------
>  drivers/net/phy/bcm63xx.c      | 15 +--------------
>  drivers/net/phy/bcm7xxx.c      | 15 +--------------
>  drivers/net/phy/bcm87xx.c      | 14 +-------------
>  drivers/net/phy/broadcom.c     | 15 +--------------
>  drivers/net/phy/cicada.c       | 15 +--------------
>  drivers/net/phy/davicom.c      | 15 +--------------
>  drivers/net/phy/et1011c.c      | 17 +++--------------
>  drivers/net/phy/icplus.c       | 15 +--------------
>  drivers/net/phy/lxt.c          | 15 +--------------
>  drivers/net/phy/marvell.c      | 15 +--------------
>  drivers/net/phy/micrel.c       | 15 +--------------
>  drivers/net/phy/national.c     | 17 +++--------------
>  drivers/net/phy/qsemi.c        | 17 +++--------------
>  drivers/net/phy/realtek.c      | 13 +------------
>  drivers/net/phy/smsc.c         | 14 +-------------
>  drivers/net/phy/ste10Xp.c      | 15 +--------------
>  drivers/net/phy/vitesse.c      | 14 +-------------
>  include/linux/phy.h            | 24 ++++++++++++++++++++++++
>  21 files changed, 52 insertions(+), 274 deletions(-)
> 
