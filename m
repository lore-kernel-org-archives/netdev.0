From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 08/10] tcp: use tp->tcp_mstamp in tcp_clean_rtx_queue()
Date: Tue, 25 Apr 2017 13:53:35 -0400
Message-ID: <CADVnQym-TS+WKH+fuDidQqePoggTr-Uof09=B610+HsnvTALEA@mail.gmail.com>
References: <20170425171541.3417-1-edumazet@google.com> <20170425171541.3417-9-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35652 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1946600AbdDYRyG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:54:06 -0400
Received: by mail-oi0-f52.google.com with SMTP id j201so180974923oih.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:54:06 -0700 (PDT)
In-Reply-To: <20170425171541.3417-9-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 1:15 PM, Eric Dumazet <edumazet@google.com> wrote:
> Following patch will remove ack_time from struct tcp_sacktag_state
>
> Same info is now found in tp->tcp_mstamp
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
