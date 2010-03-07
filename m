From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Sun, 07 Mar 2010 15:31:33 -0800 (PST)
Message-ID: <20100307.153133.263972737.davem@davemloft.net>
References: <20100306050656.GA6812@linux.vnet.ibm.com>
	<20100306065655.GA14326@gondor.apana.org.au>
	<20100306070739.GB14470@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41635
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751233Ab0CGXbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 18:31:14 -0500
In-Reply-To: <20100306070739.GB14470@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 6 Mar 2010 15:07:39 +0800

> On Sat, Mar 06, 2010 at 02:56:55PM +0800, Herbert Xu wrote:
>> On Fri, Mar 05, 2010 at 09:06:56PM -0800, Paul E. McKenney wrote:
>>
>> > Shouldn't the br_mdb_get() code path be using hlist_for_each_entry_rcu()
>> > in __br_mdb_ip_get(), then?  Or is something else going on here?
>> 
>> Indeed it should, I'll fix this up too.
> 
> bridge: Use RCU list primitive in __br_mdb_ip_get
> 
> As Paul McKenney correctly pointed out, __br_mdb_ip_get needs
> to use the RCU list walking primitive in order to work correctly
> on platforms where data-dependency ordering is not guaranteed.
> 
> Reported-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
