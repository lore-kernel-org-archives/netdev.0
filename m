From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bgmac: Fix infinite loop in bgmac_dma_tx_add()
Date: Fri, 15 Jul 2016 16:04:29 -0700 (PDT)
Message-ID: <20160715.160429.706188117972117187.davem@davemloft.net>
References: <1468622572-15443-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de,
	jon.mason@broadcom.com, bcm-kernel-feedback-list@broadcom.com,
	nbd@nbd.name
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55944 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbcGOXEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:04:31 -0400
In-Reply-To: <1468622572-15443-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 15 Jul 2016 15:42:52 -0700

> Nothing is decrementing the index "i" while we are cleaning up the
> fragments we could not successful transmit.
> 
> Fixes: 9cde94506eacf ("bgmac: implement scatter/gather support")
> Reported-by: coverity (CID 1352048)
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks.
