From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] tg3: Add set_eee and get_eee handlers.
Date: Mon, 20 May 2013 00:14:32 -0700 (PDT)
Message-ID: <20130520.001432.1672523597176879654.davem@davemloft.net>
References: <1368894415-27678-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741Ab3ETHOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 03:14:34 -0400
In-Reply-To: <1368894415-27678-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Sat, 18 May 2013 09:26:51 -0700

> This series adds support for modifying EEE settings via ethtool. Since this can
> impact Link Flap Avoidance, the driver pulls the current hardware settings if
> LFA is enabled. This is similar to how we do the link settings to avoid a flap.
> 
> v2: Fixes pointed out by Ben Hutchings.
>  - Use MDIO_AN_EEE_LPABLE to set the lp_advertised field.
>  - Check that tx_lpi_timer is within valid range.

Series applied, thanks.
