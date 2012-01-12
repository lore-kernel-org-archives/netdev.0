From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] gianfar: Fix missing sock reference when
 processing TX time stamps
Date: Thu, 12 Jan 2012 15:26:14 -0800 (PST)
Message-ID: <20120112.152614.1461396801832529188.davem@davemloft.net>
References: <1326187612-27384-1-git-send-email-manfred.rudigier@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com,
	avorontsov@mvista.com, richardcochran@gmail.com,
	eric.dumazet@gmail.com
To: manfred.rudigier@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278Ab2ALX02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 18:26:28 -0500
In-Reply-To: <1326187612-27384-1-git-send-email-manfred.rudigier@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manfred Rudigier <manfred.rudigier@omicron.at>
Date: Tue, 10 Jan 2012 10:26:50 +0100

> When there is not enough headroom in the skb a private copy will be made.
> However, the private copy had no reference to the socket and consequently
> no time stamp could be queued on the socket error queue during the
> skb_tstamp_tx function. This patch fixes this issue by also stealing the
> sock reference from the original skb after making the private copy.
> 
> Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>

Applied.
