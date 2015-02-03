From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sunvnet: set queue mapping when doing packet copies
Date: Mon, 02 Feb 2015 18:21:14 -0800 (PST)
Message-ID: <20150202.182114.1495760209878504465.davem@davemloft.net>
References: <54C90AED.7040404@oracle.com>
	<54CBBF89.4070800@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	eric.dumazet@gmail.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074AbbBCCVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 21:21:15 -0500
In-Reply-To: <54CBBF89.4070800@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Fri, 30 Jan 2015 12:29:45 -0500

> 
> 
> This patch fixes a bug where vnet_skb_shape() didn't set the already-selected
> queue mapping when a packet copy was required. This results in using the
> wrong queue index for stops/starts, hung tx queues and watchdog timeouts
> under heavy load.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>
> Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> 
> --
> I'm resubmitting this in its original form. Since skb_segment() doesn't do
> TCP flow control either, due to an incorrect destructor check, and those
> issues raised by Eric are a matter of fairness, while this missing queue_mapping
> assignment results in crashes, I'd like to get this piece fixed separately.

Fair enough, applied.

Please sort out the callback issues with Eric, thanks.
