From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15] tcp: TCP TS option use 1 ms clock
Date: Wed, 17 May 2017 16:06:22 -0400 (EDT)
Message-ID: <20170517.160622.1668271289507037704.davem@davemloft.net>
References: <20170516210014.31176-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, ycheng@google.com, soheil@google.com,
        weiwan@google.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36178 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753011AbdEQUGY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 16:06:24 -0400
In-Reply-To: <20170516210014.31176-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 16 May 2017 13:59:59 -0700

> TCP Timestamps option is defined in RFC 7323
> 
> Traditionally on linux, it has been tied to the internal
> 'jiffy' variable, because it had been a cheap and good enough
> generator.
> 
> Unfortunately some distros use HZ=250 or even HZ=100 leading
> to not very useful TCP timestamps.
> 
> For TCP flows in the DC, Google has used usec resolution for more
> than two years with great success [1].
> RCVBUF autotuning is more precise.
> 
> This series converts tp->tcp_mstamp to a plain u64 value storing
> a 1 usec TCP clock.
> 
> This choice will allow us to upstream the 1 usec TS option as
> discussed in IETF 97.
> 
> Kathleen Nichols [2] and others advocate for 1ms TS clocks for
> network analysis. (1ms being the lowest value supported by RFC 7323.)
> 
> [1] https://www.ietf.org/proceedings/97/slides/slides-97-tcpm-tcp-options-for-low-latency-00.pdf
> [2] http://netseminar.stanford.edu/seminars/02_02_17.pdf

Series applied, thanks Eric.
