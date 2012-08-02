From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Thu, 02 Aug 2012 16:37:36 -0700 (PDT)
Message-ID: <20120802.163736.2195802807682348146.davem@davemloft.net>
References: <878ve0dtw3.fsf@xmission.com>
	<1343903310.9299.184.camel@edumazet-glaptop>
	<87wr1h35zg.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, xemul@parallels.com, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746Ab2HBXhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 19:37:37 -0400
In-Reply-To: <87wr1h35zg.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 02 Aug 2012 04:09:39 -0700

> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
>> If ifindex are per network space, I guess we'll need to change
>> arp_hashfn() or else we'll use some slots more than others.
> 
> Darn.  I hate being right about there being a few places to fix
> up.
> 
> ndisc_hashfn also has the same limitation.

And netlabel's inteface hashing as well.

LLC works with ifindex hashing and is not namespace aware.  It's
should therefore limited to &init_net and therefore OK.  Likewise
for the CAN code.
