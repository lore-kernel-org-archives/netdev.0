From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: increment retransmit counters in tlp and fast open
Date: Tue, 29 Apr 2014 09:44:54 -0400
Message-ID: <CADVnQymZdLuHeaDGTF8NSz0SMbzu=DKkwQkDX6KD5Mh=RhoERA@mail.gmail.com>
References: <1398747629.29914.143.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:59150 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757434AbaD2No4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 09:44:56 -0400
Received: by mail-wi0-f177.google.com with SMTP id cc10so454289wib.16
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 06:44:55 -0700 (PDT)
In-Reply-To: <1398747629.29914.143.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 1:00 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
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

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
