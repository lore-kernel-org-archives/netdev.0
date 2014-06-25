From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2]tg3: Change nvram command timeout value to 50ms
Date: Wed, 25 Jun 2014 15:56:54 -0700 (PDT)
Message-ID: <20140625.155654.1467075108784621076.davem@davemloft.net>
References: <1403332095-30038-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: prashant@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761AbaFYW4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 18:56:54 -0400
In-Reply-To: <1403332095-30038-1-git-send-email-prashant@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant@broadcom.com>
Date: Fri, 20 Jun 2014 23:28:15 -0700

> Commit 506724c463fcd63477a5e404728a980b71f80bb7 "tg3: Override clock,
> link aware and link idle mode during NVRAM dump" changed the timeout
> value for nvram command execution from 100ms to 1ms. But the 1ms
> timeout value was only sufficient for nvram read operations but not
> write operations for most of the devices supported by tg3 driver.
> This patch sets the MAX to 50ms. Also it uses usleep_range instead
> of udelay.
> 
> Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Suggested-by: David Miller <davem@davemloft.net>

Applied, thank you.
