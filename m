From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] net: systemport: only update UMAC_CMD
 if something changed
Date: Thu, 08 May 2014 23:44:27 -0400 (EDT)
Message-ID: <20140508.234427.1071681345426052376.davem@davemloft.net>
References: <1399498564-22037-1-git-send-email-f.fainelli@gmail.com>
	<1399498564-22037-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33060 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424AbaEIDo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 23:44:29 -0400
In-Reply-To: <1399498564-22037-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed,  7 May 2014 14:36:03 -0700

> Changes in v3:
> - make sure the second and third line after CMD_SPEED_MASK are aligned
>   properly
 ...
> +		reg &= ~((CMD_SPEED_MASK << CMD_SPEED_SHIFT) |
> +				CMD_HD_EN | CMD_RX_PAUSE_IGNORE |
> +				CMD_TX_PAUSE_IGNORE);

Still not right, in fact it looks like you didn't change anything
at all.

It should look like:

		reg &= ~((CMD_SPEED_MASK << CMD_SPEED_SHIFT) |
			 CMD_HD_EN | CMD_RX_PAUSE_IGNORE |
			 CMD_TX_PAUSE_IGNORE);
