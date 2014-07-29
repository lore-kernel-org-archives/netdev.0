From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: make tipc_buf_append() more robust
Date: Mon, 28 Jul 2014 18:34:23 -0700 (PDT)
Message-ID: <20140728.183423.698426909730741975.davem@davemloft.net>
References: <1406314089-5446-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbaG2BeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 21:34:24 -0400
In-Reply-To: <1406314089-5446-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri, 25 Jul 2014 14:48:09 -0400

> As per comment from David Miller, we try to make the buffer reassembly
> function more resilient to user errors than it is today.
> 
> - We check that the "*buf" parameter always is set, since this is
>   mandatory input.
> 
> - We ensure that *buf->next always is set to NULL before linking in
>   the buffer, instead of relying of the caller to have done this.
> 
> - We ensure that the "tail" pointer in the head buffer's control
>   block is initialized to NULL when the first fragment arrives.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied to net-next, since this doesn't really fix any bugs.
