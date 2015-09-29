From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: help compiler generate better code in
 eth_get_headlen
Date: Mon, 28 Sep 2015 22:51:38 -0700 (PDT)
Message-ID: <20150928.225138.363029814550861853.davem@davemloft.net>
References: <20150928104713.12016.65491.stgit@canyon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425AbbI2Fvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:51:40 -0400
In-Reply-To: <20150928104713.12016.65491.stgit@canyon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 28 Sep 2015 12:47:14 +0200

> Noticed that the compiler (gcc version 4.8.5 20150623 (Red Hat 4.8.5-4) (GCC))
> generated suboptimal assembler code in eth_get_headlen().
> 
> This early return coding style is usually not an issue, on super scalar CPUs,
> but the compiler choose to put the return statement after this very unlikely
> branch, thus creating larger jump down to the likely code path.
> 
> Performance wise, I could measure slightly less L1-icache-load-misses
> and less branch-misses, and an improvement of 1 nanosec with an IP-forwarding
> use-case with 257 bytes packets with ixgbe (CPU i7-4790K @ 4.00GHz).
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, thanks Jesper.
