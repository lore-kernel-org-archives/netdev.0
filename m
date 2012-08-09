From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] bonding: don't allow the master to become its slave
Date: Thu, 09 Aug 2012 16:43:31 -0700 (PDT)
Message-ID: <20120809.164331.1709422829981798177.davem@davemloft.net>
References: <20120809195539.GB1783@minipsycho.orion>
	<1344546593.2593.24.camel@bwh-desktop.uk.solarflarecom.com>
	<22811.1344547628@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jpirko@redhat.com, fbl@redhat.com,
	netdev@vger.kernel.org, andy@greyhouse.net, lchiquitto@suse.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759875Ab2HIXnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 19:43:32 -0400
In-Reply-To: <22811.1344547628@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Thu, 09 Aug 2012 14:27:08 -0700

> 	If that's hard to do (and it might be; I'm not aware of a
> standard way to run up and down those stacks of interfaces, which might
> not always be vlans in the middle), there's still the priv_flags &
> IFF_BONDING test that bonding could (and probably should) do itself as
> well.  The team driver could presumably have a similar test, although I
> seem to recall that team was allowed to nest.
> 
> 	FWIW, I've seen both the top and bottom halves of that picture
> in use (i.e., bonds consisting of vlans as slaves or bonds with vlans
> configured above them), but not combined as in your diagram.

We're basically looking for cycles in a complex graph.

Some combination of Jay and Ben's most recent patches, with some minor
modifications, ought to do it.
