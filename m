From: Ben Dooks <ben@simtec.co.uk>
Subject: Re: [PATCH] net: KS8851 needs to depend on MII
Date: Wed, 22 Jul 2009 12:19:17 +0100
Message-ID: <4A66F5B5.2050606@simtec.co.uk>
References: <1248261411-12533-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:53290 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752551AbZGVLTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 07:19:50 -0400
In-Reply-To: <1248261411-12533-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Beregalov wrote:
> fix this build error when CONFIG_MII is not set
> drivers/net/ks8851.c:999: undefined reference to `generic_mii_ioctl'
> drivers/net/ks8851.c:1050: undefined reference to `mii_link_ok'
> drivers/net/ks8851.c:1056: undefined reference to `mii_nway_restart'
> drivers/net/ks8851.c:1044: undefined reference to `mii_ethtool_sset'
> drivers/net/ks8851.c:1038: undefined reference to `mii_ethtool_gset'

thanks, my test system has an DM9000 so that selected CONFIG_MII for me.

> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
Acked-by: Ben Dooks <ben@simtec.co.uk>

> ---
>  drivers/net/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 1dbaffd..3ed49f1 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1732,6 +1732,7 @@ config KS8842
>  config KS8851
>         tristate "Micrel KS8851 SPI"
>         depends on SPI
> +       select MII
>         help
>           SPI driver for Micrel KS8851 SPI attached network chip.
>  


-- 
Ben Dooks, Software Engineer, Simtec Electronics

http://www.simtec.co.uk/
