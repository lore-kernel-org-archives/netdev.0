From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH]  FIXED_MII_100_FDX
Date: Sat, 26 Jan 2008 09:40:15 -0600
Message-ID: <F46728E2-6406-4411-9E24-F12D5DAC2491@kernel.crashing.org>
References: <479AD93D.30202@pikatech.com>
Mime-Version: 1.0 (Apple Message framework v915)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
To: Sean MacLennan <smaclennan@pikatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59598 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751985AbYAZPkg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jan 2008 10:40:36 -0500
In-Reply-To: <479AD93D.30202@pikatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 26, 2008, at 12:54 AM, Sean MacLennan wrote:

> On the last git pull,  FIXED_MII_100_FDX was removed from the phy
> Kconfig, but the Kconfig for CPMAC still tried to select it.
>
> Cheers,
>   Sean
>
> Signed-off-by: Sean MacLennan <smaclennan@pikatech.com>
> ---
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 9af05a2..297a4b5 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1710,7 +1710,6 @@ config CPMAC
> 	depends on NET_ETHERNET && EXPERIMENTAL && AR7
> 	select PHYLIB
> 	select FIXED_PHY
> -	select FIXED_MII_100_FDX
> 	help
> 	  TI AR7 CPMAC Ethernet support

This patch isn't sufficient.  AntonV has posted a proper fix that we  
need Jeff to pick up.

http://ozlabs.org/pipermail/linuxppc-dev/2008-January/050330.html

- k
