From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2] net: codel: Avoid undefined behavior from
 signed overflow
Date: Mon, 04 Nov 2013 20:01:44 -0500 (EST)
Message-ID: <20131104.200144.759235525186812439.davem@davemloft.net>
References: <20131031211055.10355.98182.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, dave.taht@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997Ab3KEBBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 20:01:46 -0500
In-Reply-To: <20131031211055.10355.98182.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 31 Oct 2013 22:10:55 +0100

> From: Jesper Dangaard Brouer <netoptimizer@brouer.com>
> 
> As described in commit 5a581b367 (jiffies: Avoid undefined
> behavior from signed overflow), according to the C standard
> 3.4.3p3, overflow of a signed integer results in undefined
> behavior.
> 
> To fix this, do as the above commit, and do an unsigned
> subtraction, and interpreting the result as a signed
> two's-complement number.  This is based on the theory from
> RFC 1982 and is nicely described in wikipedia here:
>  https://en.wikipedia.org/wiki/Serial_number_arithmetic#General_Solution
> 
> A side-note, I have seen practical issues with the previous logic
> when dealing with 16-bit, on a 64-bit machine (gcc version
> 4.4.5). This were 32-bit, which I have not observed issues with.
> 
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: Jesper Dangaard Brouer <netoptimizer@brouer.com>

Applied, thanks for working through this Jesper.
