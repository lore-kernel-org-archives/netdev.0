From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] net: systemport: only update UMAC_CMD
 if something changed
Date: Wed, 07 May 2014 15:59:57 -0400 (EDT)
Message-ID: <20140507.155957.393285971385097449.davem@davemloft.net>
References: <1399317652-20078-1-git-send-email-f.fainelli@gmail.com>
	<1399317652-20078-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301AbaEGT77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 15:59:59 -0400
In-Reply-To: <1399317652-20078-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon,  5 May 2014 12:20:51 -0700

> +		reg &= ~((CMD_SPEED_MASK << CMD_SPEED_SHIFT) |
> +				CMD_HD_EN | CMD_RX_PAUSE_IGNORE |
> +				CMD_TX_PAUSE_IGNORE);

While you're here use indentation more consistent with the rest of the
networking for this kind of expression.

On the second and third line, indent to the first column after the openning
parenthesis on the first line.

Thanks.
