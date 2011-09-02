From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, 1/2] ethtool: Implement private flags interface for
 ethtool application.
Date: Fri, 02 Sep 2011 16:55:24 -0400 (EDT)
Message-ID: <20110902.165524.1076389492712310664.davem@davemloft.net>
References: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: carolyn.wyborny@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755784Ab1IBUzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 16:55:32 -0400
In-Reply-To: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>
Date: Fri,  2 Sep 2011 13:50:30 -0700

> This patch completes the user space implementation of the private
> flags inteface in ethtool. Using -b/-B options.
> 
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>

The only use case you show here is something generic which other
chips have, Energy Efficient Ethernet.

Making an attribute private which is present widely amonst various
networking chips makes no sense at all.

It deserved a generic ethtool flag.
