From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] ipv6: implement consistent hashing for
 equal-cost multipath routing
Date: Thu, 01 Dec 2016 15:26:38 -0500 (EST)
Message-ID: <20161201.152638.37238894730380417.davem@davemloft.net>
References: <583C9093.7060404@uclouvain.be>
        <20161128.153209.2135257061368558724.davem@davemloft.net>
        <1480511568.3649771.803688521.5B47BE8F@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.lebrun@uclouvain.be, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43746 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934261AbcLAU0l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:26:41 -0500
In-Reply-To: <1480511568.3649771.803688521.5B47BE8F@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 30 Nov 2016 14:12:48 +0100

> David, one question: do you remember if you measured with linked lists
> at that time or also with arrays. I actually would expect small arrays
> that entirely fit into cachelines to be actually faster than our current
> approach, which also walks a linked list, probably the best algorithm to
> trash cache lines. I ask because I currently prefer this approach more
> than having large allocations in the O(1) case because of easier code
> and easier management.

I did not try this and I do agree with you that for extremely small table
sizes a list or array would perform better because of the cache behavior.
