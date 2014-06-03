From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: Fixes for new ethtool RSS commands
Date: Mon, 02 Jun 2014 23:07:42 -0700 (PDT)
Message-ID: <20140602.230742.1657606763843010424.davem@davemloft.net>
References: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, VenkatKumar.Duvvuru@Emulex.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39592 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbaFCGHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 02:07:45 -0400
In-Reply-To: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 03 Jun 2014 02:49:21 +0100

> This addresses several problems I previously identified with the new
> ETHTOOL_{G,S}RSSH commands:
> 
> 1. Missing validation of reserved parameters
> 2. Vague documentation
> 3. Use of unnamed magic number
> 4. No consolidation with existing driver operations
> 
> I don't currently have access to suitable network hardware, but have
> tested these changes with a dummy driver that can support various
> combinations of operations and sizes, together with (a) Debian's ethtool
> 3.13 (b) ethtool 3.14 with the submitted patch to use ETHTOOL_{G,S}RSSH
> and minor adjustment for fixes 1 and 3.
> 
> v2: Update RSS operations in vmxnet3 too

Pulled, will push out once my build test completes ;-)
