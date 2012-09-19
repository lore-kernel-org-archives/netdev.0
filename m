From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: more accurate network taps in transmit
 path
Date: Wed, 19 Sep 2012 15:33:26 -0400 (EDT)
Message-ID: <20120919.153326.1748109929856208648.davem@davemloft.net>
References: <1348037089.26523.397.camel@edumazet-glaptop>
	<20120919.141637.531173978256020103.davem@davemloft.net>
	<1348078872.26523.1233.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamie.gloudon@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab2ISTd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:33:28 -0400
In-Reply-To: <1348078872.26523.1233.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Sep 2012 20:21:12 +0200

> On Wed, 2012-09-19 at 14:16 -0400, David Miller wrote:
> 
>> Are you really sure that all the network tap implementations can
>> handle software GSO segmented skbs using skb->next linkage?
>> 
>> Because that is what they can potentially see after this change.
> 
> I dont think so, because skb->next is NULL at the points I call the
> network tap.
> 
> Or did I miss something ?

Indeed, you're right.  I misread the control flow here.

Applied, thanks a lot Eric.
