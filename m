From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: esp: Convert NETDEBUG to pr_info
Date: Thu, 06 Nov 2014 15:11:40 -0500 (EST)
Message-ID: <20141106.151140.2037815990664349357.davem@davemloft.net>
References: <1415230568.6634.36.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	kaber@trash.net, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbaKFULn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 15:11:43 -0500
In-Reply-To: <1415230568.6634.36.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 05 Nov 2014 15:36:08 -0800

> Commit 64ce207306de ("[NET]: Make NETDEBUG pure printk wrappers")
> originally had these NETDEBUG printks as always emitting.
> 
> Commit a2a316fd068c ("[NET]: Replace CONFIG_NET_DEBUG with sysctl")
> added a net_msg_warn sysctl to these NETDEBUG uses.
> 
> Convert these NETDEBUG uses to normal pr_info calls.
> 
> This changes the output prefix from "ESP: " to include
> "IPSec: " for the ipv4 case and "IPv6: " for the ipv6 case.
> 
> These output lines are now like the other messages in the files.
> 
> Other miscellanea:
> 
> Neaten the arithmetic spacing to be consistent with other
> arithmetic spacing in the files.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
