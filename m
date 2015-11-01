From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: linearize arriving NAME_DISTR and
 LINK_PROTO buffers
Date: Sun, 01 Nov 2015 12:04:45 -0500 (EST)
Message-ID: <20151101.120445.368286749630299472.davem@davemloft.net>
References: <1446052193-27155-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbbKAREr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 12:04:47 -0500
In-Reply-To: <1446052193-27155-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 28 Oct 2015 13:09:53 -0400

> Testing of the new UDP bearer has revealed that reception of
> NAME_DISTRIBUTOR, LINK_PROTOCOL/RESET and LINK_PROTOCOL/ACTIVATE
> message buffers is not prepared for the case that those may be
> non-linear.
> 
> We now linearize all such buffers before they are delivered up to the
> generic reception layer.
> 
> In order for the commit to apply cleanly to 'net' and 'stable', we do
> the change in the function tipc_udp_recv() for now. Later, we will post
> a commit to 'net-next' moving the linearization to generic code, in
> tipc_named_rcv() and tipc_link_proto_rcv().
> 
> Fixes: commit d0f91938bede ("tipc: add ip/udp media type")
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied and queued up for -stable, thanks.
