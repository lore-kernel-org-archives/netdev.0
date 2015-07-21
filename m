From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] stmmac clean up for 4.3 part1
Date: Mon, 20 Jul 2015 20:46:15 -0700 (PDT)
Message-ID: <20150720.204615.1806841438159186089.davem@davemloft.net>
References: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, arnd@arndb.de, b.galvani@gmail.com,
	netdev@vger.kernel.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbbGUDqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 23:46:16 -0400
In-Reply-To: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Fri, 17 Jul 2015 00:26:04 +0200

> This patch set continues the conversion of the dwmac glue layers
> to more proper platform drivers. The first part of the patch set
> cleans up stmmac_platform a bit. Refactors code from the common
> probe function and exports two functions that will be used in
> the dwmac-* drivers.
> 
> Second part converts two simple dwmac-* drivers to have their
> own probe function and use the exported functions. This brings
> us closer to point where stmmac_platform is only a library of
> common functions for the dwmac-* drivers to use.
> 
> The plan next is:
>  * add probe functions to the rest of the dwmac-* drivers
>  * move probe function in stmmac_platform to dwmac-generic
>  * remove struct stmmac_of_data and let those drivers
>    that actually need match data handle it themselves
>  * clean up include/linux/stmmac.h
> 
> Note that this patch set has only been tested on lpc18xx so
> testing on other platforms is greatly appreciated.
> 
> Previous parts can be found here:
> http://www.spinics.net/lists/netdev/msg328997.html
> http://www.spinics.net/lists/netdev/msg329932.html

Series applied, thanks.
