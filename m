From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4, linux-2.6.30.4
Date: Wed, 12 Aug 2009 14:55:49 -0700 (PDT)
Message-ID: <20090812.145549.228391386.davem@davemloft.net>
References: <bb6e06c00908121147h2dab7d0kf5841a40956c5c56@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: slot.daniel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34631
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751668AbZHLVzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 17:55:39 -0400
In-Reply-To: <bb6e06c00908121147h2dab7d0kf5841a40956c5c56@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Slot <slot.daniel@gmail.com>
Date: Wed, 12 Aug 2009 20:47:44 +0200

> RFC 4653 specifies Non-Congestion Robustness (NCR) for TCP.
> In the absence of explicit congestion notification from the network, TCP
> uses loss as an indication of congestion.
> One of the ways TCP detects loss is using the arrival of three duplicate
> acknowledgments.
> However, this heuristic is not always correct,
> notably in the case when network paths reorder segments (for whatever
> reason), resulting in degraded performance.

Linux's TCP stack already has sophisticated reordering detection.

> TCP-NCR is designed to mitigate this degraded performance by increasing the
> number of duplicate acknowledgments required to trigger loss recovery,
> based on the current state of the connection, in an effort to better
> disambiguate true segment loss from segment reordering.

We already have code in the stack which tries to detect packet
reordering with a high level of sophistication.
