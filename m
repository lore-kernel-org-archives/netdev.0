From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] llc: Fix races between llc2 handler use and
 (un)registration
Date: Tue, 14 Aug 2012 16:52:29 -0700 (PDT)
Message-ID: <20120814.165229.1188235930691444293.davem@davemloft.net>
References: <1344862120.824.139.camel@deadeye.wl.decadent.org.uk>
	<1344862255.824.142.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754801Ab2HNXwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 19:52:31 -0400
In-Reply-To: <1344862255.824.142.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 13 Aug 2012 13:50:55 +0100

> When registering the handlers, any state they rely on must be
> completely initialised first.  When unregistering, we must wait until
> they are definitely no longer running.  llc_rcv() must also avoid
> reading the handler pointers again after checking for NULL.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
