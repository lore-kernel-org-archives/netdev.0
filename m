From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH net] tcp: increment retransmit counters in tlp and fast open
Date: Mon, 28 Apr 2014 22:51:15 -0700
Message-ID: <CAB_+Fg7f22Xbhf1hy8+Jj5e_BuBto0_25f=xxTWjBcYLCJzS8g@mail.gmail.com>
References: <1398747629.29914.143.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:38218 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755127AbaD2FvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 01:51:16 -0400
Received: by mail-oa0-f44.google.com with SMTP id n16so8335841oag.17
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 22:51:16 -0700 (PDT)
In-Reply-To: <1398747629.29914.143.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2014 at 10:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Both TLP and Fast Open call __tcp_retransmit_skb() instead of
> tcp_retransmit_skb() to avoid changing tp->retrans_out.
>
> This has the side effect of missing SNMP counters increments as well
> as tcp_info tcpi_total_retrans updates.
>
> Fix this by moving the stats increments of into __tcp_retransmit_skb()
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
Acked-by: Nandita Dukkipati <nanditad@google.com>
