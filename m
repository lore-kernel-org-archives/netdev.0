From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] llc2: Fix silent failure of llc_station_init()
Date: Tue, 14 Aug 2012 16:52:11 -0700 (PDT)
Message-ID: <20120814.165211.2173895464645202364.davem@davemloft.net>
References: <1344862120.824.139.camel@deadeye.wl.decadent.org.uk>
	<1344862199.824.140.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541Ab2HNXwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 19:52:13 -0400
In-Reply-To: <1344862199.824.140.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 13 Aug 2012 13:49:59 +0100

> llc_station_init() creates and processes an event skb with no effect
> other than to change the state from DOWN to UP.  Allocation failure is
> reported, but then ignored by its caller, llc2_init().  Remove this
> possibility by simply initialising the state as UP.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
