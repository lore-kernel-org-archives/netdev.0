From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] [SCTP]: Force update of the rto when processing
 HB-ACK
Date: Tue, 30 Jan 2007 14:35:50 -0800 (PST)
Message-ID: <20070130.143550.58786541.davem@davemloft.net>
References: <1170196371.15598.34.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44612
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751866AbXA3Wfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 17:35:51 -0500
In-Reply-To: <1170196371.15598.34.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Tue, 30 Jan 2007 14:32:51 -0800

> [SCTP]: Force update of the rto when processing HB-ACK
> 
> When processing a HEARTBEAT-ACK it's possible that the transport rto
> timers will not be updated because a prior T3-RTX processing would
> have cleared the rto_pending flag on the transport.  However, if
> we received a valid HEARTBEAT-ACK, we want to force update the
> rto variables, so re-set the rto_pending flag before calling
> sctp_transport_update_rto().
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

I'll apply this, thanks Sridhar.
