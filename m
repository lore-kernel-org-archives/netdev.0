From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 17:54:35 -0700 (PDT)
Message-ID: <20120619.175435.1705108432673390966.davem@davemloft.net>
References: <20120619.163911.2094057156011157978.davem@davemloft.net>
	<1340151666.6871.81.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab2FTAyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 20:54:38 -0400
In-Reply-To: <1340151666.6871.81.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 20 Jun 2012 01:21:06 +0100

> This works only because MAX_INET_PROTOS is defined as 256, so that hash
> == protocol.  If we were ever to change MAX_INET_PROTOS then we would
> need to add a whole lot of protocol checks, but this isn't particularly
> obvious!  Perhaps it would be better to remove the 'hashing' altogether?

We never have changed the value and we never will.  The hash is
perfect, what's the big deal?
