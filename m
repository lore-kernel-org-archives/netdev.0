From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Sun, 12 Sep 2010 13:24:45 -0700 (PDT)
Message-ID: <20100912.132445.112598025.davem@davemloft.net>
References: <20100912104534.GA2056@del.dom.local>
	<20100912.085833.226777368.davem@davemloft.net>
	<87zkvmvir9.fsf@benpfaff.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: blp@cs.stanford.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42707
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752802Ab0ILUY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Sep 2010 16:24:28 -0400
In-Reply-To: <87zkvmvir9.fsf@benpfaff.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Pfaff <blp@cs.stanford.edu>
Date: Sun, 12 Sep 2010 12:55:54 -0700

> David Miller <davem@davemloft.net> writes:
> 
>>> 3) since skb_clone has some cost too, why e.g. saving only the pointer
>>>    to the tail of the list in skb_shared_info isn't enough?
>>
>> Then we won't get the rest of the advantages of using list_head such
>> as prefetching during traversals, automatic debugging facilities, et al.
> 
> Did you see the recent patch from Andi Kleen where he proposes
> removing this prefetching in most situations because the costs
> outweigh the benefits on most modern architectures?
>         http://permalink.gmane.org/gmane.linux.kernel/1033281
> 
> I'm not saying that list_head doesn't have other advantages
> though.

Yes I saw it and I somewhat disagree with him, but don't care
enough to argue with him about it.  There are much more important
things to apply my mind and time to at the moment :-)
