From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2.6.26] phy: Change mii_bus id field to a string
Date: Sat, 12 Apr 2008 05:01:27 -0400
Message-ID: <48007A67.3090806@pobox.com>
References: <1207787893-9200-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59354 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757982AbYDLJBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:01:31 -0400
In-Reply-To: <1207787893-9200-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> Having the id field be an int was making more complex bus topologies
> excessively difficult.  For now, just convert it to a string, and
> change all instances of "bus->id = val" to
> snprintf(id, MII_BUS_ID_LEN, "%x", val).
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
>  arch/powerpc/platforms/82xx/ep8248e.c     |    2 +-
>  arch/powerpc/platforms/pasemi/gpio_mdio.c |    2 +-
>  arch/powerpc/sysdev/fsl_soc.c             |    5 +++--
>  drivers/net/au1000_eth.c                  |    6 +++---
>  drivers/net/bfin_mac.c                    |    2 +-
>  drivers/net/cpmac.c                       |    5 ++---
>  drivers/net/fec_mpc52xx.c                 |    2 +-
>  drivers/net/fec_mpc52xx_phy.c             |    2 +-
>  drivers/net/fs_enet/fs_enet-main.c        |    4 ++--
>  drivers/net/fs_enet/mii-bitbang.c         |    4 ++--
>  drivers/net/fs_enet/mii-fec.c             |    4 ++--
>  drivers/net/gianfar_mii.c                 |    2 +-
>  drivers/net/macb.c                        |    2 +-
>  drivers/net/pasemi_mac.c                  |    2 +-
>  drivers/net/phy/fixed.c                   |    2 +-
>  drivers/net/sb1250-mac.c                  |    2 +-
>  drivers/net/ucc_geth.c                    |    2 +-
>  drivers/net/ucc_geth.h                    |    2 +-
>  drivers/net/ucc_geth_mii.c                |    2 +-
>  include/linux/fsl_devices.h               |    2 +-
>  include/linux/phy.h                       |   12 ++++++++----
>  21 files changed, 36 insertions(+), 32 deletions(-)

applied


