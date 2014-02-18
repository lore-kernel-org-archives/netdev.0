From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: failed transmissions should return error
Date: Tue, 18 Feb 2014 18:11:28 -0500 (EST)
Message-ID: <20140218.181128.1171749217306683994.davem@davemloft.net>
References: <1392730190-20050-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	ying.xue@windriver.com, paul.gortmaker@windriver.com,
	jon.maloy@ericsson.com, maloy@donjonn.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357AbaBRXLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 18:11:31 -0500
In-Reply-To: <1392730190-20050-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Tue, 18 Feb 2014 14:29:50 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> When a message could not be sent out because the destination
> node or link could not be found, the full message size is
> returned from sendmsg() as if it had been sent successfully.
> An application will then get a false indication that it's
> making forward progress. This problem has existed since the
> initial commit in 2.6.16.
> 
> We change this to return -ENETUNREACH if the message cannot be
> delivered due to the destination node/link being unavailable.
> We also get rid of the redundant tipc_reject_msg call since
> freeing the buffer and doing a tipc_port_reject_sections
> accomplishes exactly the same thing.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>

This does not apply cleanly to net-next, please respin.
