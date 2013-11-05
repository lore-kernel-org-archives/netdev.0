From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/7] IBM Akebono: Add support for a new PHY to the IBM
 emac driver
Date: Tue, 5 Nov 2013 18:16:44 +0000
Message-ID: <1383675404.2868.8.camel@bwh-desktop.uk.level5networks.com>
References: <1383629471-16979-1-git-send-email-alistair@popple.id.au>
	 <1383629471-16979-3-git-send-email-alistair@popple.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linuxppc-dev@lists.ozlabs.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Alistair Popple <alistair@popple.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:12122 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754945Ab3KESQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 13:16:49 -0500
In-Reply-To: <1383629471-16979-3-git-send-email-alistair@popple.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-05 at 16:31 +1100, Alistair Popple wrote:
[...]
> --- a/drivers/net/ethernet/ibm/emac/Kconfig
> +++ b/drivers/net/ethernet/ibm/emac/Kconfig
> @@ -55,6 +55,10 @@ config IBM_EMAC_RGMII
>  	bool
>  	default n
>  
> +config IBM_EMAC_RGMII_WOL
> +	bool
> +	default n
> +
[...]

So no-one can even build-test this at present!

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
