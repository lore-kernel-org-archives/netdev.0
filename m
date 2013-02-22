From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix SYN-data space mis-accounting
Date: Fri, 22 Feb 2013 15:14:01 -0500 (EST)
Message-ID: <20130222.151401.47849208236481976.davem@davemloft.net>
References: <1361559546-1538-1-git-send-email-ycheng@google.com>
	<1361562058.3683.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754759Ab3BVUOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 15:14:07 -0500
In-Reply-To: <1361562058.3683.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 22 Feb 2013 11:40:58 -0800

> On Fri, 2013-02-22 at 10:59 -0800, Yuchung Cheng wrote:
>> In fast open the sender unncessarily reduces the space available
>> for data in SYN by 12 bytes.  This is because in the sender
>> incorrectly reserves space for TS option twice in tcp_send_syn_data():
>> tcp_mtu_to_mss() already accounts for TS option space. But it further
>> reserves MAX_TCP_OPTION_SPACE when computing the payload space.
>> 
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, and queue up for -stable, thanks everyone.
