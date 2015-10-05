From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] tcp: lockless listener fixes and
 improvement
Date: Mon, 05 Oct 2015 02:46:58 -0700 (PDT)
Message-ID: <20151005.024658.1312815855818451072.davem@davemloft.net>
References: <1444018091-21987-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbbJEJb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 05:31:27 -0400
In-Reply-To: <1444018091-21987-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sun,  4 Oct 2015 21:08:06 -0700

> This fixes issues with TCP FastOpen vs lockless listeners,
> and SYNACK being attached to request sockets.
> 
> Then, last patch brings performance improvement for
> syncookies generation and validation.
> 
> Tested under a 4.3 Mpps SYNFLOOD attack, new perf profile looks
> like :
>     12.11%  [kernel]  [k] sha_transform
>      5.83%  [kernel]  [k] tcp_conn_request
>      4.59%  [kernel]  [k] __inet_lookup_listener
>      4.11%  [kernel]  [k] ipt_do_table
>      3.91%  [kernel]  [k] tcp_make_synack
>      3.05%  [kernel]  [k] fib_table_lookup
>      2.74%  [kernel]  [k] sock_wfree
>      2.66%  [kernel]  [k] memcpy_erms
>      2.12%  [kernel]  [k] tcp_v4_rcv

Series applied, thanks Eric.
