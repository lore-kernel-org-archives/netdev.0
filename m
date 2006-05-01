From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH] Add some new card IDs to hostap_cs
Date: Mon, 1 May 2006 11:04:25 -0700
Message-ID: <20060501180425.GB32508@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tayrelbas03.tay.hp.com ([161.114.80.246]:62093 "EHLO
	tayrelbas03.tay.hp.com") by vger.kernel.org with ESMTP
	id S932189AbWEASEb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 14:04:31 -0400
To: Marcin Juszkiewicz <openembedded@hrw.one.pl>,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marcin Juszkiewicz wrote :
> 
> When I use pcmcia-cs then my Pretec WiFi card is handled by hostap
> driver and everything is working fine. Recently I switched to
> pcmciautils and after card insert orinoco modules are loaded. I prefer
> to use hostap modules because they work the same under 2.4 and 2.6
> kernels (with orinoco I have to use 0.13e ones because never ones does
> not work under 2.4/arm).

	I'm sorry, but I have to veto part of your patch because it's
clear you don't know what you are doing.
	Some of those cards are Orinoco or Symbol cards. The HostAP
driver do *NOT* properly support them (try to scan or to use ad-hoc
mode). Only the Orinoco driver do support those cards.
	Therefore, the HostAP driver should never bind to those cards.

	My howto do explain those things in details. Please don't do
those kind of patches as it will break support for those of use using
those cards.

> + PCMCIA_DEVICE_MANF_CARD(0x0089, 0x0001), /* "Intel PRO/Wireless
2011" */

	That's a Symbol card. I know, I have one.

> +	/*card "3Com AirConnect"*/
> +	PCMCIA_DEVICE_PROD_ID12("3Com", "3CRWE737A AirConnect Wireless LAN PC Card",
> +			0x90952d33, 0xfa4f2ce9),

	That's a Symbol card. I know, I have two.

> +	/*card "MELCO WLI-PCM-L11"*/
> +	PCMCIA_DEVICE_PROD_ID12( "MELCO", "WLI-PCM-L11",
> +			0xc549cac9, 0xc2f6de9b),
> +
> +	/*card "MELCO WLI-PCM-L11G"*/
> +	PCMCIA_DEVICE_PROD_ID12( "MELCO", "WLI-PCM-L11G",
> +			0xfebebb55, 0x6db62357),
> +
> +	/*card "MELCO WLI-PCM-L11G"*/
> +	PCMCIA_DEVICE_PROD_ID12( "BUFFALO", "WLI-PCM-L11G",
> +			0x6cdab6ea, 0xc364d25d),
> +
> +	/*card "Buffalo WLI2-CF-S11"*/
> +	PCMCIA_DEVICE_PROD_ID12( "BUFFALO", "WLI2-CF-S11",
> +			0x798caeca, 0xe38746ab),
> +

	I believe, from the report I got, that those are Orinoco cards.

> +	/*card "NCR WaveLAN/IEEE Adapter"*/
> +	PCMCIA_DEVICE_PROD_ID12( "NCR", "WaveLAN/IEEE",
> +			0x7b03a1a1, 0x1e9b31cf),

	That's an Orinoco card. I know, I have zillion of them.

	Regards,

	Jean
