From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] net: fixup time stamping batch #1
Date: Sun, 19 Jun 2011 16:36:10 -0700 (PDT)
Message-ID: <20110619.163610.220895682157570365.davem@davemloft.net>
References: <cover.1308489767.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60537 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754781Ab1FSXgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 19:36:12 -0400
In-Reply-To: <cover.1308489767.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sun, 19 Jun 2011 15:31:38 +0200

> As Eric Dumazet helpfully pointed out, the placing the transmit time
> stamp hook after giving the skb to hardware races with the completion
> ISR, for those drivers which free the buffer in the ISR.
> 
> This series fixes up the first batch of time stamping hook patches.

Series applied, thanks.
