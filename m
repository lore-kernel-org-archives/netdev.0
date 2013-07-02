From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: call udp_push_pending_frames when uncorking
 a socket with AF_INET pending data
Date: Tue, 02 Jul 2013 12:45:30 -0700 (PDT)
Message-ID: <20130702.124530.1934465740187090037.davem@davemloft.net>
References: <20130701182130.GC8937@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754951Ab3GBTpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 15:45:31 -0400
In-Reply-To: <20130701182130.GC8937@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 1 Jul 2013 20:21:30 +0200

> We accidentally call down to ip6_push_pending_frames when uncorking
> pending AF_INET data on a ipv6 socket. This results in the following
> splat (from Dave Jones):
 ...
> This patch adds a check if the pending data is of address family AF_INET
> and directly calls udp_push_ending_frames from udp_v6_push_pending_frames
> if that is the case.
> 
> This bug was found by Dave Jones with trinity.
> 
> (Also move the initialization of fl6 below the AF_INET check, even if
> not strictly necessary.)
> 
> Cc: Dave Jones <davej@redhat.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable.
