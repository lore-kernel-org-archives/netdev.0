From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tcp: deduplicate TCP_SKB_CB(skb)->when
Date: Fri, 05 Sep 2014 17:49:57 -0700 (PDT)
Message-ID: <20140905.174957.2301014826043548460.davem@davemloft.net>
References: <1409956413-29472-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbaIFAt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:49:58 -0400
In-Reply-To: <1409956413-29472-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri,  5 Sep 2014 15:33:31 -0700

> TCP_SKB_CB(skb)->when has different meaning in output and input paths.
> 
> In output path, it contains a timestamp.
> In input path, it contains an ISN, chosen by tcp_timewait_state_process()
> 
> Its usage in output path is obsolete after usec timestamping.
> Lets simplify and clean this.

Nice cleanup, applied, thanks Eric.
