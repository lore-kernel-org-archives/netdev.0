From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: fix bug in link protocol message
 create function
Date: Tue, 26 May 2015 19:43:42 -0400 (EDT)
Message-ID: <20150526.194342.115254427393620467.davem@davemloft.net>
References: <1432633219-3354-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbEZXno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 19:43:44 -0400
In-Reply-To: <1432633219-3354-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue, 26 May 2015 05:40:19 -0400

> In commit dd3f9e70f59f43a5712eba9cf3ee4f1e6999540c
> ("tipc: add packet sequence number at instant of transmission") we
> made a change with the consequence that packets in the link backlog
> queue don't contain valid sequence numbers.
> 
> However, when we create a link protocol message, we still use the
> sequence number of the first packet in the backlog, if there is any,
> as "next_sent" indicator in the message. This may entail unnecessary
> retransissions or stale packet transmission when there is very low
> traffic on the link.
> 
> This commit fixes this issue by only using the current value of
> tipc_link::snd_nxt as indicator.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.
