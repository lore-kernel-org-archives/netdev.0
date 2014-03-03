From: David Miller <davem@davemloft.net>
Subject: Re: [nf-next PATCH V3 0/5] netfilter: conntrack: optimization,
 remove central spinlock
Date: Mon, 03 Mar 2014 16:00:46 -0500 (EST)
Message-ID: <20140303.160046.1024219314107578405.davem@davemloft.net>
References: <20140303134319.2615.9293.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, eric.dumazet@gmail.com,
	pablo@netfilter.org, netdev@vger.kernel.org, fw@strlen.de,
	kaber@trash.net
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752636AbaCCVAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 16:00:49 -0500
In-Reply-To: <20140303134319.2615.9293.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 03 Mar 2014 14:44:16 +0100

> This patchset change the conntrack locking and provides a huge
> performance improvements.
> 
> This patchset is based upon Eric Dumazet's proposed patch:
>   http://thread.gmane.org/gmane.linux.network/268758/focus=47306
> I have in agreement with Eric Dumazet, taken over this patch (and
> turned it into a entire patchset).
> 
> Primary focus is to remove the central spinlock nf_conntrack_lock.
> This requires several steps to be acheived.
 ...

For series:

Signed-off-by: David S. Miller <davem@davemloft.net>
