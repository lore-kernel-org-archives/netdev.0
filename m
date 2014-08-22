From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Free completed tx skbs promptly
Date: Thu, 21 Aug 2014 21:55:10 -0700 (PDT)
Message-ID: <20140821.215510.1020820955556312798.davem@davemloft.net>
References: <1408620886-20065-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755832AbaHVEzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 00:55:11 -0400
In-Reply-To: <1408620886-20065-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu, 21 Aug 2014 17:04:46 +0530

> Description of problem:
> The NIC card is not reporting back to the driver the transmitted skbs,
> so they get stuck in the TX ring causing issues with reference
> counters in other kernel components.
> 
> Developed a new Automatic Egress Queue Update firmware facility to slowly tick
> through Egress Queues and send back any outstanding CIDX Updates which are
> laying around.
> 
> Based on original work by Casey Leedom <leedom@chelsio.com>
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thank you.
