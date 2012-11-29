From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2 3/9] net: frag, move LRU list maintenance
 outside of rwlock
Date: Thu, 29 Nov 2012 13:36:44 -0500 (EST)
Message-ID: <20121129.133644.1495776898566315155.davem@davemloft.net>
References: <1354213492.3299.22.camel@edumazet-glaptop>
	<20121129.133108.427624036846294750.davem@davemloft.net>
	<1354213993.3299.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, tgraf@suug.ch, amwang@redhat.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902Ab2K2Sgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:36:46 -0500
In-Reply-To: <1354213993.3299.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Nov 2012 10:33:13 -0800

> On Thu, 2012-11-29 at 13:31 -0500, David Miller wrote:
> 
>> I think a per-cpu hash might make more sense.
>> 
>> This would scale our limits to the size of the system.
>> 
>> I'm willing to be convinced otherwise, but it seems the most
>> sensible thing to do.
> 
> It would break in many cases, when frags are spreaded on different cpus.

Indeed, ignore my stupid idea.
