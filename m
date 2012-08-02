From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net 0/3] Prevent extreme TSO parameters from stalling
 TX queues
Date: Thu, 02 Aug 2012 00:20:45 -0700 (PDT)
Message-ID: <20120802.002045.2029236086125448605.davem@davemloft.net>
References: <1343699476.2667.69.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	greearb@candelatech.com, eric.dumazet@gmail.com,
	shemminger@vyatta.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab2HBHUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 03:20:46 -0400
In-Reply-To: <1343699476.2667.69.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 31 Jul 2012 02:51:16 +0100

> The following changes fix a potential DoS by peers or local users on
> network interfaces using the sfc driver (and possibly others) with TSO
> enabled (as it is by default).
> 
> Please apply patches 1 and 2 to the net tree and your stable update
> queue.  I'm not sure whether patch 3 is really important.
> 
> Ben.
> 
> Ben Hutchings (3):
>   net: Allow driver to limit number of GSO segments per skb
>   sfc: Fix maximum number of TSO segments and minimum TX queue size
>   tcp: Apply device TSO segment limit earlier

Series applied, thanks Ben.  I think patch #3 does matter, because
anything in TCP that cares about the "limit" now must make both
tests.
