From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/17] dccp/tcp: constify listener sock
Date: Fri, 25 Sep 2015 13:42:42 -0700 (PDT)
Message-ID: <20150925.134242.2091340029551837446.davem@davemloft.net>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933204AbbIYUmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 16:42:46 -0400
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri, 25 Sep 2015 07:39:07 -0700

> Another patch bomb to prepare lockless TCP/DCCP LISTEN handling. 
> 
> SYNACK retransmits are built and sent without listener socket
> being locked. Soon, initial SYNACK packets will have same property.
> 
> This series makes sure we did not something wrong with this model,
> by adding a const qualifier in all the paths taken from synack building
> and transmit, for IPv4/IPv6 and TCP/dccp.
> 
> The only potential problem was the rewrite of ecn bits for connections
> with DCTCP as congestion module, but this was a very minor one.
 ...
> David, to apply these patches you'll need to merge net tree into net-next
> first. Thanks !

I was able to apply them cleanly to net-next as-is, so I did so.
