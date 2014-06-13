From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: ipv4: do not waste time in
 __udp4_lib_mcast_demux_lookup
Date: Fri, 13 Jun 2014 15:39:47 -0700 (PDT)
Message-ID: <20140613.153947.1190933976866000224.davem@davemloft.net>
References: <1402614786.3645.500.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sbohrer@rgmadvisors.com, drheld@google.com,
	willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbaFMWjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2014 18:39:48 -0400
In-Reply-To: <1402614786.3645.500.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Jun 2014 16:13:06 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Its too easy to add thousand of UDP sockets on a particular bucket,
> and slow down an innocent multicast receiver.
> 
> Early demux is supposed to be an optimization, we should avoid spending
> too much time in it.
> 
> It is interesting to note __udp4_lib_demux_lookup() only tries to
> match first socket in the chain.
> 
> 10 is the threshold we already have in __udp4_lib_lookup() to switch
> to secondary hash.
> 
> Fixes: 421b3885bf6d5 ("udp: ipv4: Add udp early demux")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: David Held <drheld@google.com>

Applied and queued up for -stable, thanks Eric.
