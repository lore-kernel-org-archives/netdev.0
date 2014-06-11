From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: fix potential bug in function
 tipc_backlog_rcv
Date: Wed, 11 Jun 2014 15:02:05 -0700 (PDT)
Message-ID: <20140611.150205.49850151033059080.davem@davemloft.net>
References: <1402330098-4719-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47457 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020AbaFKWCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:02:06 -0400
In-Reply-To: <1402330098-4719-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon,  9 Jun 2014 11:08:18 -0500

> In commit 4f4482dcd9a0606a30541ff165ddaca64748299b ("tipc: compensate
> for double accounting in socket rcv buffer") we access 'truesize' of
> a received buffer after it might have been released by the function
> filter_rcv().
> 
> In this commit we correct this by reading the value of 'truesize' to
> the stack before delivering the buffer to filter_rcv().
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
