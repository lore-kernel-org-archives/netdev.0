From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gianfar: Restore link state settings after MAC
 reset
Date: Thu, 13 Aug 2015 21:26:41 -0700 (PDT)
Message-ID: <20150813.212641.807345031571015710.davem@davemloft.net>
References: <1439473837-30442-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbbHNE0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 00:26:42 -0400
In-Reply-To: <1439473837-30442-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Thu, 13 Aug 2015 16:50:37 +0300

> There are some MAC registers that need to be kept in sync
> with the link state parameters, see adjust_link().
> However, after a MAC soft reset default values for
> these registers are assumed.  In some cases (excepting
> if down/ if up for example) adjust_link() does not see
> that these values were reset to default because the
> priv->old* link parameters were left unchanged.
> So, reset the priv->old* link params as well during a
> MAC reset to let adjust_link() restore the MAC link
> settings to the actual link state values.
> 
> Fixes following case, for example:
> Setting link to 100M, changing MTU (implies MAC reset),
> link state remains unchanged to 100M but MAC registers
> were reset to default (1G) breaking the connectivity w/
> the PHY.  Closing and re-opening the interface would
> restore the MAC link parameters to the correct values.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied, thanks.
