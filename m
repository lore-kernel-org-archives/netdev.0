From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: systemport: fix tx work done in TX napi
 poll
Date: Wed, 12 Nov 2014 22:21:56 -0500 (EST)
Message-ID: <20141112.222156.1637241639796486486.davem@davemloft.net>
References: <1415835643-13767-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49890 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753561AbaKMDV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 22:21:58 -0500
In-Reply-To: <1415835643-13767-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 12 Nov 2014 15:40:43 -0800

> With commit d75b1ade567 ("net: less interrupt masking in NAPI") napi
> repoll is done only when work_done == budget. bcm_sysport_tx_poll()
> always returns 0 whether or not we completed the poll quantum.
> 
> Fix this by returning either 0 when we did complete the TX ring reclaim,
> or budget to trigger a repoll.
> 
> Fixes: d75b1ade567 ("net: less interrupt masking in NAPI")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
