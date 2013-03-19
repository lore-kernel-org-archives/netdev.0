From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] inet: limit length of fragment queue hash table bucket lists
Date: Tue, 19 Mar 2013 15:31:13 +0100
Message-ID: <20130319143113.GA24909@order.stressinduktion.org>
References: <20130315213230.GB24041@order.stressinduktion.org> <20130319.100324.927922515830950770.davem@davemloft.net> <1363702840.3232.104.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44499 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755574Ab3CSObO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 10:31:14 -0400
Content-Disposition: inline
In-Reply-To: <1363702840.3232.104.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 19, 2013 at 03:20:40PM +0100, Jesper Dangaard Brouer wrote:
> I think it's overkill to implement this now.  I just want this patch in
> as a safeguard.
> 
> The idea I discussed with Eric, will remove the need for this patch.
> The idea is to drop the LRU lists, increase the hash size a bit, and do
> cleanup/eviction directly on the frag hash tables.  And e.g. only allow
> 5 frag queue elements in each hash bucket... but more work and testing
> is needed before I have something ready.

Thats cool, I won't rebase the patch.

Thanks,

  Hannes
