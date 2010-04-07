From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] TIPC: Updated topology subscription protocol
 according to latest spec
Date: Tue, 06 Apr 2010 19:51:13 -0700 (PDT)
Message-ID: <20100406.195113.229269173.davem@davemloft.net>
References: <1270590052-975-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47027
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753181Ab0DGCvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 22:51:10 -0400
In-Reply-To: <1270590052-975-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue, 6 Apr 2010 17:40:52 -0400

> This patch makes it explicit in the API that all fields in subscriptions and events exchanged with the Topology Server must be in
> network byte order.
> It also ensures that all fields of a subscription are compared when cancelling a subscription, in order to avoid inadvertent
> cancelling of the wrong subscription.
> Finally, the tipc module version is updated to 2.0.0, to reflect the API change.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied to net-next-2.6, thanks.
