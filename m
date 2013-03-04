From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix double-counted receiver RTT when leaving
 receiver fast path
Date: Mon, 04 Mar 2013 14:16:08 -0500 (EST)
Message-ID: <20130304.141608.981016306872498634.davem@davemloft.net>
References: <1362414185-9874-1-git-send-email-ncardwell@google.com>
	<1362416133.15793.105.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, ycheng@google.com,
	nanditad@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758158Ab3CDTQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 14:16:09 -0500
In-Reply-To: <1362416133.15793.105.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 04 Mar 2013 08:55:33 -0800

> On Mon, 2013-03-04 at 11:23 -0500, Neal Cardwell wrote:
>> We should not update ts_recent and call tcp_rcv_rtt_measure_ts() both
>> before and after going to step5. That wastes CPU and double-counts the
>> receiver-side RTT sample.
>> 
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
