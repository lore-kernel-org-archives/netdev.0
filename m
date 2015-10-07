From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH] net: mdio-octeon: Drop obsolete Kconfig advice
Date: Wed, 7 Oct 2015 09:20:48 -0700
Message-ID: <56154660.3070608@caviumnetworks.com>
References: <20151007102638.335e9762@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	David Daney <david.daney@cavium.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0100.outbound.protection.outlook.com ([157.56.110.100]:25776
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754275AbbJGQUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 12:20:55 -0400
In-Reply-To: <20151007102638.335e9762@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2015 01:26 AM, Jean Delvare wrote:
> "Y" was the right answer for MDIO_OCTEON when this option was only
> available on CAVIUM_OCTEON_SOC. But now that the option is visible on
> all (64-bit) systems, this piece of advice no longer makes sense. This
> helper module is selected automatically by drivers which need it
> anyway.
>
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> Fixes: a6d6786452 ("net: mdio-octeon: Modify driver to work on both ThunderX and Octeon")
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Sunil Goutham <sgoutham@cavium.com>
> Cc: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>
> Cc: David Daney <david.daney@cavium.com>
> Cc: David S. Miller <davem@davemloft.net>

Jean, good catch:
Acked-by: David Daney <david.daney@cavium.com>


> ---
>   drivers/net/phy/Kconfig |    2 --
>   1 file changed, 2 deletions(-)
>
> --- linux-4.3-rc4.orig/drivers/net/phy/Kconfig	2015-09-20 23:32:34.000000000 +0200
> +++ linux-4.3-rc4/drivers/net/phy/Kconfig	2015-10-07 10:18:46.260452322 +0200
> @@ -168,8 +168,6 @@ config MDIO_OCTEON
>   	  busses. It is required by the Octeon and ThunderX ethernet device
>   	  drivers.
>
> -	  If in doubt, say Y.
> -
>   config MDIO_SUN4I
>   	tristate "Allwinner sun4i MDIO interface support"
>   	depends on ARCH_SUNXI
>
>
