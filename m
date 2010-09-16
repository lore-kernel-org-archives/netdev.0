From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: fix a race in nf_ct_ext_create()
Date: Thu, 16 Sep 2010 20:00:04 +0200
Message-ID: <4C925B24.8020900@trash.net>
References: <1283269682.2550.111.camel@edumazet-laptop> <20100831155137.GE2421@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49484 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755568Ab0IPSAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 14:00:05 -0400
In-Reply-To: <20100831155137.GE2421@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31.08.2010 17:51, Paul E. McKenney wrote:
> On Tue, Aug 31, 2010 at 05:48:02PM +0200, Eric Dumazet wrote:
>> > As soon as rcu_read_unlock() is called, there is no guarantee current
>> > thread can safely derefence t pointer, rcu protected.
>> > 
>> > Fix is to copy t->alloc_size in a temporary variable.
> Yow!!!  Good catch!!!
> 
> Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
