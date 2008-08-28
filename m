From: Andi Kleen <andi@firstfloor.org>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 09:26:23 +0200
Message-ID: <20080828072623.GJ26610@one.firstfloor.org>
References: <87zlmyr5nz.fsf@basil.nowhere.org> <20080827.142941.50104491.davem@davemloft.net> <20080827144800.5f9fc5b4@extreme> <20080827.150955.118944272.davem@davemloft.net> <48B643C3.9040502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	andi@firstfloor.org, davej@redhat.com, netdev@vger.kernel.org,
	j.w.r.degoede@hhs.nl
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51721 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbYH1HXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 03:23:48 -0400
Content-Disposition: inline
In-Reply-To: <48B643C3.9040502@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You are right. For TCP hash table thats probably hard to implement.

The alternative would be to use some kind of cache optimized
tree. While they have in theory more steps if you assume that
the upper levels of the tree are very small and usually are cached
these steps could be very cheap.

-Andi
-- 
ak@linux.intel.com
