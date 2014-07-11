From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 05/11] net: bcmgenet: request Wake-on-LAN
 interrupt
Date: Fri, 11 Jul 2014 13:41:04 -0700 (PDT)
Message-ID: <20140711.134104.340349639131622061.davem@davemloft.net>
References: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
	<1405032384-24006-6-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709AbaGKUlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 16:41:05 -0400
In-Reply-To: <1405032384-24006-6-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 10 Jul 2014 15:46:18 -0700

> +	priv->wol_irq_disabled = 1;
 ...
> +	unsigned int wol_irq_disabled;

This should also be a bool.
