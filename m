From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v5 09/11] act_police: improved accuracy at
 high rates
Date: Tue, 12 Feb 2013 19:01:52 -0500 (EST)
Message-ID: <20130212.190152.74731512570051284.davem@davemloft.net>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	<1360663929-1023-10-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755441Ab3BMABy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 19:01:54 -0500
In-Reply-To: <1360663929-1023-10-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 12 Feb 2013 11:12:07 +0100

> Current act_police uses rate table computed by the "tc" userspace program,
> which has the following issue:
> 
> The rate table has 256 entries to map packet lengths to
> token (time units).  With TSO sized packets, the 256 entry granularity
> leads to loss/gain of rate, making the token bucket inaccurate.
> 
> Thus, instead of relying on rate table, this patch explicitly computes
> the time and accounts for packet transmission times with nanosecond
> granularity.
> 
> This is a followup to 56b765b79e9a78dc7d3f8850ba5e5567205a3ecd

Same comment here about referencing commits properly.

> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks.
