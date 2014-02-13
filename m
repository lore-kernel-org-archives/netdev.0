From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tipc: fix message corruption bug for deferred
 packets
Date: Thu, 13 Feb 2014 16:35:41 -0500 (EST)
Message-ID: <20140213.163541.735423321393675744.davem@davemloft.net>
References: <1392115106-16178-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	ying.xue@windriver.com, paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbaBMVfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 16:35:44 -0500
In-Reply-To: <1392115106-16178-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Tue, 11 Feb 2014 11:38:26 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> If a packet received on a link is out-of-sequence, it will be
> placed on a deferred queue and later reinserted in the receive
> path once the preceding packets have been processed. The problem
> with this is that it will be subject to the buffer adjustment from
> link_recv_buf_validate twice. The second adjustment for 20 bytes
> header space will corrupt the packet.
> 
> We solve this by tagging the deferred packets and bail out from
> receive buffer validation for packets that have already been
> subjected to this.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.
