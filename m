From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: limit length of fragment queue hash table
 bucket lists
Date: Tue, 19 Mar 2013 10:28:09 -0400 (EDT)
Message-ID: <20130319.102809.988375215904563701.davem@davemloft.net>
References: <20130315213230.GB24041@order.stressinduktion.org>
	<20130319.100324.927922515830950770.davem@davemloft.net>
	<1363702840.3232.104.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: jbrouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756553Ab3CSO2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 10:28:11 -0400
In-Reply-To: <1363702840.3232.104.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Date: Tue, 19 Mar 2013 15:20:40 +0100

> I think it's overkill to implement this now.  I just want this patch in
> as a safeguard.
> 
> The idea I discussed with Eric, will remove the need for this patch.
> The idea is to drop the LRU lists, increase the hash size a bit, and do
> cleanup/eviction directly on the frag hash tables.  And e.g. only allow
> 5 frag queue elements in each hash bucket... but more work and testing
> is needed before I have something ready.

Fair enough.
