From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3] htb: improved accuracy at high rates
Date: Sat, 03 Nov 2012 15:25:39 -0400 (EDT)
Message-ID: <20121103.152539.2120748963636667268.davem@davemloft.net>
References: <1351699451-79317-1-git-send-email-j.vimal@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: j.vimal@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab2KCTZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:25:41 -0400
In-Reply-To: <1351699451-79317-1-git-send-email-j.vimal@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vimalkumar <j.vimal@gmail.com>
Date: Wed, 31 Oct 2012 09:04:11 -0700

> Current HTB (and TBF) uses rate table computed by the "tc"
> userspace program, which has the following issue:
> 
> The rate table has 256 entries to map packet lengths
> to token (time units).  With TSO sized packets, the
> 256 entry granularity leads to loss/gain of rate,
> making the token bucket inaccurate.
> 
> Thus, instead of relying on rate table, this patch
> explicitly computes the time and accounts for packet
> transmission times with nanosecond granularity.
> 
> This greatly improves accuracy of HTB with a wide
> range of packet sizes.
 ...
> Signed-off-by: Vimalkumar <j.vimal@gmail.com>

Applied, thanks.
