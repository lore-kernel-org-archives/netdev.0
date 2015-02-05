From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] cxgb4: Add low latency socket busy_poll
 support
Date: Wed, 04 Feb 2015 23:56:10 -0800 (PST)
Message-ID: <20150204.235610.54093520486544328.davem@davemloft.net>
References: <1423044172-23586-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbbBEH4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 02:56:11 -0500
In-Reply-To: <1423044172-23586-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed,  4 Feb 2015 15:32:52 +0530

> cxgb_busy_poll, corresponding to ndo_busy_poll, gets called by the socket
> waiting for data.
> 
> With busy_poll enabled, improvement is seen in latency numbers as observed by
> collecting netperf TCP_RR numbers.
> Below are latency number, with and without busy-poll, in a switched environment
> for a particular msg size:
> netperf command: netperf -4 -H <ip> -l 30 -t TCP_RR -- -r1,1
> Latency without busy-poll: ~16.25 us
> Latency with busy-poll   : ~08.79 us
> 
> Based on original work by Kumar Sanghvi <kumaras@chelsio.com>
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
> V2: fix napi poll return value for repoll, thanks to pointers by
>     Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
