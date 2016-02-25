From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] appletalk: Pass IP-over-DDP packets through when
 'ipddp0' interface is not present
Date: Thu, 25 Feb 2016 14:33:53 -0500 (EST)
Message-ID: <20160225.143353.284231681606348501.davem@davemloft.net>
References: <1456237153.4577.35.camel@seering.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: adam@seering.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933579AbcBYTd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 14:33:56 -0500
In-Reply-To: <1456237153.4577.35.camel@seering.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adam Seering <adam@seering.org>
Date: Tue, 23 Feb 2016 09:19:13 -0500

> Let userspace programs transmit and receive raw IP-over-DDP packets
> with a kernel where "ipddp" was compiled as a module but is not loaded
> (so no "ipddp0" network interface is exposed).  This makes the "module
> is not loaded" behavior match the "module was never compiled" behavior.
> 
> Signed-off-by: Adam Seering <adam@seering.org>

I think a better approache is to somehow autoload the module.
