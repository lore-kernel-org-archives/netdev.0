From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] vxlan: release rt when found circular route
Date: Tue, 10 Dec 2013 22:02:46 -0500 (EST)
Message-ID: <20131210.220246.172138980019997711.davem@davemloft.net>
References: <1386230631-2504-1-git-send-email-fan.du@windriver.com>
	<20131206.151407.756289328683473825.davem@davemloft.net>
	<52A562EB.9050606@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab3LKDCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 22:02:48 -0500
In-Reply-To: <52A562EB.9050606@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Mon, 9 Dec 2013 14:27:55 +0800

> From: Fan Du <fan.du@windriver.com>
> Date: Mon, 9 Dec 2013 10:33:53 +0800
> Subject: [PATCHv2 net] vxlan: release rt when found circular route
> 
> Otherwise causing dst memory leakage.
> Have Checked all other type tunnel device transmit implementation,
> no such things happens anymore.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> ---
> v2: use rt_tx_error label to release rt.

Applied and queued up for -stable, thanks.
