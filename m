From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dp83640: Fix length check for event timestamp
 status messages
Date: Fri, 22 Aug 2014 12:36:16 -0700 (PDT)
Message-ID: <20140822.123616.814889773296037742.davem@davemloft.net>
References: <1408627024-12932-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: christian.riesch@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbaHVTgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 15:36:17 -0400
In-Reply-To: <1408627024-12932-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Riesch <christian.riesch@omicron.at>
Date: Thu, 21 Aug 2014 15:17:04 +0200

> Event timestamp status messages have a variable length, ranging from
> 1 to 5 words (16 bit words). The current code however requires
> a minimum message length of sizeof(*phy_txts). In most cases this
> condition is fulfilled due to padding bytes. However, if several events
> are signaled in a single message, padding bytes may not be present.
> For short event timestamp status messages, the length check will fail,
> and the event timestamp will be dropped.
> 
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>

Applied.
