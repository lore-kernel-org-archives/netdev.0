From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: Teach to listen for multiple unicast
 addresses.
Date: Thu, 21 May 2009 15:15:17 -0700 (PDT)
Message-ID: <20090521.151517.119887326.davem@davemloft.net>
References: <m163fwflga.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59858
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755701AbZEUWPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 18:15:19 -0400
In-Reply-To: <m163fwflga.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 19 May 2009 21:27:17 -0700

> 
> The the PACKET_ADD_MEMBERSHIP and the PACKET_DROP_MEMBERSHIP setsockopt
> calls for af_packet already has all of the infrastructure needed to subscribe
> to multiple mac addresses.  All that is missing is a flag to say that
> the address we want to listen on is a unicast address.
> 
> So introduce PACKET_MR_UNICAST and wire it up to dev_unicast_add and
> dev_unicast_delete.
> 
> Additionally I noticed that errors from dev_mc_add were not propagated
> from packet_dev_mc so fix that.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>

Looks good, applied to net-next-2.6
