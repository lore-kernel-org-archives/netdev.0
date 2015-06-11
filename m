From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: disconnect socket directly after probe failure
Date: Wed, 10 Jun 2015 22:05:44 -0700 (PDT)
Message-ID: <20150610.220544.1966331266437134539.davem@davemloft.net>
References: <1433863632-12699-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbbFKFFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 01:05:45 -0400
In-Reply-To: <1433863632-12699-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Tue, 9 Jun 2015 17:27:12 +0200

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> If the TIPC connection timer expires in a probing state, a
> self abort message is supposed to be generated and delivered
> to the local socket. This is currently broken, and the abort
> message is actually sent out to the peer node with invalid
> addressing information. This will cause the link to enter
> a constant retransmission state and eventually reset.
> We fix this by removing the self-abort message creation and
> tear down connection immediately instead.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thank you.
