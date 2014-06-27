From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/13] tipc: new unicast transmission code
Date: Fri, 27 Jun 2014 12:56:52 -0700 (PDT)
Message-ID: <20140627.125652.1511733972619182099.davem@davemloft.net>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaF0T4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 15:56:53 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 25 Jun 2014 20:41:29 -0500

> As a step towards making the data transmission code more maintainable
> and performant, we introduce a number of new functions, both for
> building, sending and rejecting messages. The new functions will
> eventually be used for alla data transmission, user data unicast,
> service internal messaging, and multicast/broadcast.
> 
> We start with this series, where we introduce the functions, and
> let user data unicast and the internal connection protocol use them.
> The remaining users will come in a later series.
> 
> There are only minor changes to data structures, and no protocol
> changes, so the older functions can still be used in parallel for
> some time. Until the old functions are removed, we use temporary
> names for the new functions, such as tipc_build_msg2, tipc_link_xmit2.
> 
> It should be noted that the first two commits are unrelated to the
> rest of the series.

Series applied, thanks Jon.
